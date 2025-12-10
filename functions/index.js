const functions = require('firebase-functions');
const admin = require('firebase-admin');
const axios = require('axios');

admin.initializeApp();

/**
 * Kundelik API Base URL
 */
const KUNDELIK_API_BASE = 'https://api.kundelik.kz/v2';

/**
 * Cloud Function: kundelikLogin
 *
 * Handles Kundelik authentication and data retrieval via credentials-based API.
 * Acts as a secure backend proxy to avoid exposing client credentials in Flutter app.
 *
 * @param {Object} data - Request data
 * @param {string} data.username - Kundelik username
 * @param {string} data.password - Kundelik password
 * @param {Object} context - Function context
 * @returns {Object} User data from Kundelik API or error
 */
exports.kundelikLogin = functions.https.onCall(async (data, context) => {
  // Validate input parameters
  const {username, password} = data;

  if (!username || !password) {
    throw new functions.https.HttpsError(
        'invalid-argument',
        'Username and password are required',
    );
  }

  // Get Kundelik API credentials from Firebase config
  const kundelikConfig = functions.config().kundelik;

  if (!kundelikConfig || !kundelikConfig.client_id || !kundelikConfig.client_secret) {
    console.error('Kundelik config not found. Run: firebase functions:config:set kundelik.client_id="..." kundelik.client_secret="..."');
    throw new functions.https.HttpsError(
        'failed-precondition',
        'Server configuration error. Please contact support.',
    );
  }

  const clientId = kundelikConfig.client_id;
  const clientSecret = kundelikConfig.client_secret;
  const scope = 'Schools,Relatives,EduGroups,Lessons,marks,EduWorks,Avatar,EducationalInfo,CommonInfo,ContactInfo,FriendsAndRelatives,Files,Wall,Messages';

  try {
    console.log(`Attempting Kundelik login for user: ${username}`);

    // Step 1: Authenticate with Kundelik API
    let authResponse;
    try {
      authResponse = await axios.post(
          `${KUNDELIK_API_BASE}/authorizations/bycredentials`,
          null,
          {
            params: {
              client_id: clientId,
              client_secret: clientSecret,
              username: username,
              password: password,
              scope: scope,
            },
            headers: {
              'Content-Type': 'application/x-www-form-urlencoded',
            },
            timeout: 15000, // 15 second timeout
          },
      );
    } catch (authError) {
      console.error('Kundelik authentication error:', authError.response?.status, authError.response?.data);

      // Handle authentication failures
      if (authError.response) {
        const status = authError.response.status;
        const responseData = authError.response.data;

        // Invalid credentials (401 or 400)
        if (status === 401 || status === 400) {
          // Try to extract error message from HTML if present
          let errorMessage = 'Invalid username or password';

          if (typeof responseData === 'string' && responseData.includes('error__description')) {
            // Extract error from HTML
            const match = responseData.match(/<div class="error__description">\s*([^<]+)\s*<\/div>/);
            if (match && match[1]) {
              errorMessage = match[1].trim();
            }
          }

          throw new functions.https.HttpsError(
              'unauthenticated',
              errorMessage,
          );
        }

        // Server error (5xx)
        if (status >= 500) {
          throw new functions.https.HttpsError(
              'unavailable',
              'Kundelik API is temporarily unavailable. Please try again later.',
          );
        }

        // Other errors
        throw new functions.https.HttpsError(
            'unknown',
            `Kundelik API error: ${status}`,
          );
      }

      // Network error or timeout
      if (authError.code === 'ECONNABORTED' || authError.code === 'ETIMEDOUT') {
        throw new functions.https.HttpsError(
            'unavailable',
            'Connection to Kundelik timed out. Please check your internet connection and try again.',
        );
      }

      // Other network errors
      throw new functions.https.HttpsError(
          'unavailable',
          'Failed to connect to Kundelik API. Please try again later.',
      );
    }

    // Extract authentication data
    const accessToken = authResponse.data.accessToken;
    const userId = authResponse.data.userId;

    if (!accessToken || !userId) {
      console.error('Invalid auth response:', authResponse.data);
      throw new functions.https.HttpsError(
          'internal',
          'Invalid response from Kundelik API',
      );
    }

    console.log(`Authentication successful for user ID: ${userId}`);

    // Step 2: Get user information
    let userInfo;
    try {
      const userResponse = await axios.get(
          `${KUNDELIK_API_BASE}/users/me`,
          {
            headers: {
              'Access-Token': accessToken,
            },
            timeout: 10000,
          },
      );
      userInfo = userResponse.data;
    } catch (error) {
      console.error('Failed to get user info:', error.response?.status);
      throw new functions.https.HttpsError(
          'internal',
          'Failed to retrieve user information from Kundelik',
      );
    }

    // Step 3: Get person schools
    let personSchools = [];
    try {
      const personId = userInfo.personId;

      if (personId) {
        const schoolsResponse = await axios.get(
            `${KUNDELIK_API_BASE}/schools/person-schools`,
            {
              headers: {
                'Access-Token': accessToken,
              },
              timeout: 10000,
            },
        );
        personSchools = schoolsResponse.data || [];
      }
    } catch (error) {
      console.error('Failed to get person schools:', error.response?.status);
      // Non-critical error, continue with empty schools array
      personSchools = [];
    }

    // Step 4: Get person info (for birthday)
    let personInfo = null;
    try {
      const personId = userInfo.personId;

      if (personId) {
        const personResponse = await axios.get(
            `${KUNDELIK_API_BASE}/persons/${personId}`,
            {
              headers: {
                'Access-Token': accessToken,
              },
              timeout: 10000,
            },
        );
        personInfo = personResponse.data;
      }
    } catch (error) {
      console.error('Failed to get person info:', error.response?.status);
      // Non-critical error, continue without person info
    }

    // Step 5: Get student performance (for GPA) if user is a student
    let performanceData = null;
    let gpa = null;

    if (personSchools.length > 0) {
      try {
        const firstSchool = personSchools[0];
        const studentId = firstSchool.studentId;

        if (studentId) {
          const performanceResponse = await axios.get(
              `${KUNDELIK_API_BASE}/students/${studentId}/performance`,
              {
                headers: {
                  'Access-Token': accessToken,
                },
                timeout: 10000,
              },
          );
          performanceData = performanceResponse.data;

          // Calculate GPA from marks (numerical marks only)
          if (performanceData && performanceData.marks) {
            const marks = performanceData.marks;
            const numericalMarks = marks
                .map((mark) => {
                  const value = mark.value;
                  if (typeof value === 'number') {
                    return value;
                  } else if (typeof value === 'string') {
                    const parsed = parseFloat(value);
                    return isNaN(parsed) ? null : parsed;
                  }
                  return null;
                })
                .filter((mark) => mark !== null);

            if (numericalMarks.length > 0) {
              const sum = numericalMarks.reduce((a, b) => a + b, 0);
              gpa = sum / numericalMarks.length;
            }
          }
        }
      } catch (error) {
        console.error('Failed to get performance data:', error.response?.status);
        // Non-critical error, continue without performance data
      }
    }

    // Step 6: Parse birthday from person info
    let birthday = null;
    if (personInfo && personInfo.birthday) {
      try {
        // Birthday format: "YYYY-MM-DD" or timestamp
        birthday = personInfo.birthday;
      } catch (error) {
        console.error('Failed to parse birthday:', error);
      }
    }

    console.log(`Successfully retrieved data for user: ${username}`);

    // Return comprehensive data to Flutter
    return {
      success: true,
      accessToken: accessToken,
      userId: userId,
      userInfo: userInfo,
      personSchools: personSchools,
      personInfo: personInfo,
      birthday: birthday,
      gpa: gpa,
      performanceData: performanceData,
    };
  } catch (error) {
    // Re-throw HttpsError as-is
    if (error instanceof functions.https.HttpsError) {
      throw error;
    }

    // Log unexpected errors
    console.error('Unexpected error in kundelikLogin:', error);

    throw new functions.https.HttpsError(
        'internal',
        'An unexpected error occurred. Please try again later.',
    );
  }
});

/**
 * Cloud Function: kundelikSync
 *
 * Syncs existing Kundelik user data using stored access token.
 * Used for refreshing user data without re-entering credentials.
 *
 * @param {Object} data - Request data
 * @param {string} data.accessToken - Kundelik access token
 * @param {number} data.userId - Kundelik user ID
 * @param {Object} context - Function context
 * @returns {Object} Updated user data from Kundelik API or error
 */
exports.kundelikSync = functions.https.onCall(async (data, context) => {
  // Validate input
  const {accessToken, userId} = data;

  if (!accessToken || !userId) {
    throw new functions.https.HttpsError(
        'invalid-argument',
        'Access token and user ID are required',
    );
  }

  try {
    console.log(`Syncing Kundelik data for user ID: ${userId}`);

    // Get user information
    let userInfo;
    try {
      const userResponse = await axios.get(
          `${KUNDELIK_API_BASE}/users/me`,
          {
            headers: {
              'Access-Token': accessToken,
            },
            timeout: 10000,
          },
      );
      userInfo = userResponse.data;
    } catch (error) {
      if (error.response && error.response.status === 401) {
        throw new functions.https.HttpsError(
            'unauthenticated',
            'Access token expired. Please log in again.',
        );
      }
      throw new functions.https.HttpsError(
          'internal',
          'Failed to retrieve user information from Kundelik',
      );
    }

    // Get person schools
    let personSchools = [];
    try {
      const personId = userInfo.personId;

      if (personId) {
        const schoolsResponse = await axios.get(
            `${KUNDELIK_API_BASE}/schools/person-schools`,
            {
              headers: {
                'Access-Token': accessToken,
              },
              timeout: 10000,
            },
        );
        personSchools = schoolsResponse.data || [];
      }
    } catch (error) {
      console.error('Failed to get person schools:', error.response?.status);
      personSchools = [];
    }

    // Get person info
    let personInfo = null;
    try {
      const personId = userInfo.personId;

      if (personId) {
        const personResponse = await axios.get(
            `${KUNDELIK_API_BASE}/persons/${personId}`,
            {
              headers: {
                'Access-Token': accessToken,
              },
              timeout: 10000,
            },
        );
        personInfo = personResponse.data;
      }
    } catch (error) {
      console.error('Failed to get person info:', error.response?.status);
    }

    // Get performance data
    let performanceData = null;
    let gpa = null;

    if (personSchools.length > 0) {
      try {
        const firstSchool = personSchools[0];
        const studentId = firstSchool.studentId;

        if (studentId) {
          const performanceResponse = await axios.get(
              `${KUNDELIK_API_BASE}/students/${studentId}/performance`,
              {
                headers: {
                  'Access-Token': accessToken,
                },
                timeout: 10000,
              },
          );
          performanceData = performanceResponse.data;

          // Calculate GPA
          if (performanceData && performanceData.marks) {
            const marks = performanceData.marks;
            const numericalMarks = marks
                .map((mark) => {
                  const value = mark.value;
                  if (typeof value === 'number') {
                    return value;
                  } else if (typeof value === 'string') {
                    const parsed = parseFloat(value);
                    return isNaN(parsed) ? null : parsed;
                  }
                  return null;
                })
                .filter((mark) => mark !== null);

            if (numericalMarks.length > 0) {
              const sum = numericalMarks.reduce((a, b) => a + b, 0);
              gpa = sum / numericalMarks.length;
            }
          }
        }
      } catch (error) {
        console.error('Failed to get performance data:', error.response?.status);
      }
    }

    // Parse birthday
    let birthday = null;
    if (personInfo && personInfo.birthday) {
      birthday = personInfo.birthday;
    }

    console.log(`Successfully synced data for user ID: ${userId}`);

    return {
      success: true,
      userInfo: userInfo,
      personSchools: personSchools,
      personInfo: personInfo,
      birthday: birthday,
      gpa: gpa,
      performanceData: performanceData,
    };
  } catch (error) {
    if (error instanceof functions.https.HttpsError) {
      throw error;
    }

    console.error('Unexpected error in kundelikSync:', error);

    throw new functions.https.HttpsError(
        'internal',
        'An unexpected error occurred while syncing. Please try again later.',
    );
  }
});
