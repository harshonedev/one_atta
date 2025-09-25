# Reel Engagement API Documentation

This document covers the API endpoints for reel likes and shares functionality.

## App Routes (User-facing)

### Base URL: `/api/app/reels`

### 1. Toggle Like on Reel
**POST** `/:id/like`

Toggle like status for the current authenticated user on a specific reel.

**Authentication**: Required (Bearer token)

**Parameters**:
- `id` (URL parameter): Reel ID

**Response**:
```json
{
  "success": true,
  "message": "Reel liked successfully", // or "Reel unliked successfully"
  "data": {
    "isLiked": true, // or false if unliked
    "likesCount": 25,
    "reelId": "64f8b2a1c123456789abcdef"
  }
}
```

**Error Cases**:
- 404: Reel not found
- 403: Reel is private
- 400: Reel is not ready for interaction
- 401: Authentication required

---

### 2. Share Reel
**POST** `/:id/share`

Record a share action for a reel by the current authenticated user.

**Authentication**: Required (Bearer token)

**Parameters**:
- `id` (URL parameter): Reel ID

**Request Body**:
```json
{
  "shareType": "link" // Optional: "link", "social", "direct" (default: "link")
}
```

**Response**:
```json
{
  "success": true,
  "message": "Reel shared successfully",
  "data": {
    "shareUrl": "https://yourdomain.com/reels/64f8b2a1c123456789abcdef",
    "sharesCount": 15,
    "shareType": "link",
    "reelId": "64f8b2a1c123456789abcdef",
    "sharedAt": "2024-01-15T10:30:00.000Z"
  }
}
```

**Error Cases**:
- 404: Reel not found
- 403: Reel is private
- 400: Invalid share type or reel not ready
- 401: Authentication required

---

### 3. Get Reel Like Status
**GET** `/:id/like-status`

Check if the current authenticated user has liked a specific reel.

**Authentication**: Required (Bearer token)

**Parameters**:
- `id` (URL parameter): Reel ID

**Response**:
```json
{
  "success": true,
  "message": "Like status retrieved successfully",
  "data": {
    "isLiked": true,
    "likesCount": 25,
    "reelId": "64f8b2a1c123456789abcdef"
  }
}
```

---

### 4. Get Reel Statistics
**GET** `/:id/stats`

Get public engagement statistics for a reel.

**Authentication**: Not required

**Parameters**:
- `id` (URL parameter): Reel ID

**Response**:
```json
{
  "success": true,
  "message": "Reel stats retrieved successfully",
  "data": {
    "reelId": "64f8b2a1c123456789abcdef",
    "stats": {
      "views": 150,
      "likes": 25,
      "shares": 8,
      "createdAt": "2024-01-15T10:30:00.000Z"
    }
  }
}
```

---

## Admin Routes

### Base URL: `/api/admin/reels`

### 1. Get Reel Analytics
**GET** `/:id/analytics`

Get detailed engagement analytics for a specific reel (admin only).

**Authentication**: Required (Bearer token + Admin role)

**Parameters**:
- `id` (URL parameter): Reel ID

**Response**:
```json
{
  "success": true,
  "message": "Reel analytics retrieved successfully",
  "data": {
    "reelId": "64f8b2a1c123456789abcdef",
    "analytics": {
      "totalViews": 150,
      "totalLikes": 25,
      "totalShares": 8,
      "engagementRate": 22.00,
      "likesOverTime": {
        "2024-01-15": 10,
        "2024-01-16": 15
      },
      "sharesOverTime": {
        "link": {
          "2024-01-15": 3,
          "2024-01-16": 2
        },
        "social": {
          "2024-01-15": 2,
          "2024-01-16": 1
        }
      },
      "recentLikes": [
        {
          "user": {
            "_id": "64f8b2a1c123456789abcdef",
            "name": "John Doe",
            "email": "john@example.com"
          },
          "likedAt": "2024-01-16T08:30:00.000Z"
        }
      ],
      "recentShares": [
        {
          "user": {
            "_id": "64f8b2a1c123456789abcdef",
            "name": "Jane Smith",
            "email": "jane@example.com"
          },
          "shareType": "social",
          "sharedAt": "2024-01-16T09:15:00.000Z"
        }
      ]
    }
  }
}
```

---

### 2. Get Top Performing Reels
**GET** `/top-performing`

Get reels sorted by engagement metrics (admin only).

**Authentication**: Required (Bearer token + Admin role)

**Query Parameters**:
- `limit` (optional): Number of results (default: 20, max: 100)
- `sortBy` (optional): Sort criteria - "views", "likes", "shares", "engagement" (default: "engagement")

**Response**:
```json
{
  "success": true,
  "message": "Top performing reels retrieved successfully",
  "data": {
    "reels": [
      {
        "_id": "64f8b2a1c123456789abcdef",
        "caption": "Amazing blend tutorial!",
        "views": 500,
        "likesCount": 80,
        "sharesCount": 25,
        "createdAt": "2024-01-15T10:30:00.000Z",
        "tags": ["tutorial", "blend"],
        "createdBy": {
          "_id": "64f8b2a1c123456789abcdef",
          "name": "Content Creator",
          "email": "creator@example.com"
        },
        "engagementScore": 685 // Only present when sortBy is "engagement"
      }
    ],
    "sortBy": "engagement",
    "count": 20
  }
}
```

---

### 3. Moderate Reel Engagement
**DELETE** `/:id/engagement`

Remove inappropriate likes or shares from a reel (admin only).

**Authentication**: Required (Bearer token + Admin role)

**Parameters**:
- `id` (URL parameter): Reel ID

**Request Body**:
```json
{
  "userId": "64f8b2a1c123456789abcdef",
  "action": "remove_like" // or "remove_share"
}
```

**Response**:
```json
{
  "success": true,
  "message": "remove_like completed successfully",
  "data": {
    "reelId": "64f8b2a1c123456789abcdef",
    "likesCount": 24,
    "sharesCount": 8
  }
}
```

**Error Cases**:
- 404: Reel not found or no engagement found to remove
- 400: Invalid action or missing parameters
- 401: Authentication required
- 403: Admin authorization required

---

## Database Schema Changes

### Reel Model Updates

The `Reel` model has been enhanced with the following new fields:

```javascript
// Likes system
likes: [{
  userId: ObjectId (ref: User),
  likedAt: Date
}],
likesCount: Number (default: 0),

// Shares system
shares: [{
  userId: ObjectId (ref: User),
  sharedAt: Date,
  shareType: String (enum: ["link", "social", "direct"])
}],
sharesCount: Number (default: 0)
```

### New Indexes
- `likesCount: -1` - For sorting by likes
- `sharesCount: -1` - For sorting by shares
- `views: -1` - For sorting by views
- `"likes.userId": 1` - For efficient like status checks

### Model Methods
- `isLikedByUser(userId)` - Check if user has liked the reel
- `toggleLike(userId)` - Add/remove like for a user
- `addShare(userId, shareType)` - Add a share record

---

## Usage Examples

### Frontend Integration

```javascript
// Like/Unlike a reel
const toggleLike = async (reelId) => {
  try {
    const response = await fetch(`/api/app/reels/${reelId}/like`, {
      method: 'POST',
      headers: {
        'Authorization': `Bearer ${token}`,
        'Content-Type': 'application/json'
      }
    });
    const data = await response.json();
    return data;
  } catch (error) {
    console.error('Error toggling like:', error);
  }
};

// Share a reel
const shareReel = async (reelId, shareType = 'link') => {
  try {
    const response = await fetch(`/api/app/reels/${reelId}/share`, {
      method: 'POST',
      headers: {
        'Authorization': `Bearer ${token}`,
        'Content-Type': 'application/json'
      },
      body: JSON.stringify({ shareType })
    });
    const data = await response.json();
    return data;
  } catch (error) {
    console.error('Error sharing reel:', error);
  }
};

// Check like status
const checkLikeStatus = async (reelId) => {
  try {
    const response = await fetch(`/api/app/reels/${reelId}/like-status`, {
      headers: {
        'Authorization': `Bearer ${token}`
      }
    });
    const data = await response.json();
    return data;
  } catch (error) {
    console.error('Error checking like status:', error);
  }
};
```

### Environment Variables

Make sure to set the following environment variable for share URL generation:

```env
FRONTEND_URL=https://yourdomain.com
```

---

## Notes

1. **Rate Limiting**: Consider implementing rate limiting on like/share endpoints to prevent spam.

2. **Pagination**: The analytics endpoints include pagination for better performance with large datasets.

3. **Privacy**: Private reels cannot be liked or shared by other users.

4. **Soft Delete**: Deleted reels are excluded from all engagement operations.

5. **Engagement Score**: Calculated as `(likesCount * 2) + (sharesCount * 3) + views` where shares are weighted most heavily.

6. **Data Consistency**: Like and share counts are automatically updated via mongoose pre-save middleware.
