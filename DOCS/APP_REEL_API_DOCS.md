# App Reel System API Documentation (Frontend)

## Base URL
```
https://your-api-domain.com/api/app
```

## Authentication
All app reel endpoints are **public** and do not require authentication. Users can view reels and see blend details without logging in.

**Headers (Optional):**
```
Content-Type: application/json
```

---

## Endpoints

### 1. Get Reels Feed

**Endpoint:** `GET /reels`

**Description:** Get a paginated feed of public reels using cursor-based pagination for infinite scroll.

**Query Parameters:**
| Parameter | Type | Required | Default | Description |
|-----------|------|----------|---------|-------------|
| limit | number | No | 20 | Number of reels to return (max 50) |
| cursor | string | No | - | Cursor for pagination (from previous response) |

**Example Requests:**
```
GET /api/app/reels
GET /api/app/reels?limit=10
GET /api/app/reels?limit=15&cursor=2023-07-15T10:30:00.000Z_60f1b2e4d4b0f4001f5e4a3d
```

**Success Response (200):**
```json
{
  "success": true,
  "message": "Reels feed retrieved successfully",
  "data": {
    "reels": [
      {
        "id": "60f1b2e4d4b0f4001f5e4a3d",
        "caption": "Amazing multigrain blend recipe!",
        "poster_url": "https://bucket.s3.../poster.jpg",
        "video_url": "https://bucket.s3.../video.mp4",
        "duration": 45,
        "formatted_duration": "0:45",
        "tags": ["healthy", "organic", "multigrain"],
        "views": 150,
        "createdAt": "2023-07-15T10:30:00.000Z",
        "createdBy": {
          "name": "Admin User"
        },
        "blend": {
          "_id": "60f1b2e4d4b0f4001f5e4a3c",
          "name": "Multigrain Blend",
          "share_code": "MG123"
        },
        "blendSnapshot": {
          "name": "Multigrain Blend",
          "additives": [
            {
              "percentage": 70,
              "original_details": {
                "name": "Whole Wheat",
                "sku": "WW001",
                "price_per_kg": 45
              }
            },
            {
              "percentage": 20,
              "original_details": {
                "name": "Oats",
                "sku": "OT001", 
                "price_per_kg": 85
              }
            },
            {
              "percentage": 10,
              "original_details": {
                "name": "Barley",
                "sku": "BR001",
                "price_per_kg": 60
              }
            }
          ],
          "price_per_kg": 52.5,
          "share_code": "MG123"
        }
      }
    ],
    "nextCursor": "2023-07-15T09:15:00.000Z_60f1b2e4d4b0f4001f5e4a3e",
    "hasMore": true
  }
}
```

**Response Fields:**
| Field | Type | Description |
|-------|------|-------------|
| reels | array | Array of reel objects |
| nextCursor | string | Cursor for next page (null if no more) |
| hasMore | boolean | Whether there are more reels to load |

**Error Responses:**
```json
// 400 - Invalid cursor
{
  "success": false,
  "message": "Invalid cursor format"
}

// 500 - Server error
{
  "success": false,
  "message": "Failed to retrieve reels feed"
}
```

**Frontend Implementation Example:**
```javascript
class ReelsFeed {
  constructor(apiBaseUrl) {
    this.apiBaseUrl = apiBaseUrl;
    this.reels = [];
    this.cursor = null;
    this.loading = false;
    this.hasMore = true;
  }

  async loadMore(limit = 20) {
    if (this.loading || !this.hasMore) return;
    
    this.loading = true;
    try {
      const params = new URLSearchParams({ limit });
      if (this.cursor) params.append('cursor', this.cursor);
      
      const response = await fetch(`${this.apiBaseUrl}/app/reels?${params}`);
      const result = await response.json();
      
      if (result.success) {
        this.reels.push(...result.data.reels);
        this.cursor = result.data.nextCursor;
        this.hasMore = result.data.hasMore;
      }
    } catch (error) {
      console.error('Failed to load reels:', error);
    } finally {
      this.loading = false;
    }
  }

  async refresh() {
    this.reels = [];
    this.cursor = null;
    this.hasMore = true;
    await this.loadMore();
  }
}

// Usage
const feed = new ReelsFeed('https://api.oneatta.com/api');
await feed.loadMore(); // Initial load
await feed.loadMore(); // Load more for infinite scroll
```

---

### 2. Get Reel Details

**Endpoint:** `GET /reels/:id`

**Description:** Get detailed information about a specific reel including full blend details.

**Path Parameters:**
| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| id | string | Yes | Reel ID |

**Example Request:**
```
GET /api/app/reels/60f1b2e4d4b0f4001f5e4a3d
```

**Success Response (200):**
```json
{
  "success": true,
  "message": "Reel details retrieved successfully",
  "data": {
    "reel": {
      "id": "60f1b2e4d4b0f4001f5e4a3d",
      "createdBy": {
        "name": "Admin User"
      },
      "status": "ready",
      "video_url": "https://bucket.s3.../video.mp4",
      "poster_url": "https://bucket.s3.../poster.jpg",
      "duration": 45,
      "formatted_duration": "0:45",
      "caption": "Amazing multigrain blend recipe!",
      "tags": ["healthy", "organic", "multigrain"],
      "visibility": "public",
      "views": 150,
      "blend": {
        "_id": "60f1b2e4d4b0f4001f5e4a3c",
        "name": "Multigrain Blend",
        "share_code": "MG123",
        "is_public": true
      },
      "createdAt": "2023-07-15T10:30:00.000Z",
      "updatedAt": "2023-07-15T10:30:00.000Z",
      "blendDetails": {
        "name": "Multigrain Blend",
        "ingredients": [
          {
            "name": "Whole Wheat",
            "percentage": 70,
            "pricePerKg": 45
          },
          {
            "name": "Oats", 
            "percentage": 20,
            "pricePerKg": 85
          },
          {
            "name": "Barley",
            "percentage": 10,
            "pricePerKg": 60
          }
        ],
        "totalPricePerKg": 52.5,
        "shareCode": "MG123"
      }
    }
  }
}
```

**Blend Details Structure:**
```typescript
interface BlendDetails {
  name: string;
  ingredients: Array<{
    name: string;
    percentage: number;
    pricePerKg: number;
  }>;
  totalPricePerKg: number;
  shareCode: string;
}
```

**Error Responses:**
```json
// 404 - Reel not found
{
  "success": false,
  "message": "Reel not found"
}

// 403 - Private reel
{
  "success": false,
  "message": "This reel is private"
}

// 400 - Not ready
{
  "success": false,
  "message": "Reel is not ready for viewing"
}
```

---

### 3. Increment View Count

**Endpoint:** `POST /reels/:id/view`

**Description:** Record a view for a reel. Should be called when user actually watches the reel.

**Path Parameters:**
| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| id | string | Yes | Reel ID |

**Request Body:** Empty (`{}`)

**Example Request:**
```
POST /api/app/reels/60f1b2e4d4b0f4001f5e4a3d/view
```

**Success Response (200):**
```json
{
  "success": true,
  "message": "View recorded successfully",
  "data": {
    "views": 151
  }
}
```

**Error Responses:**
```json
// 404 - Reel not found
{
  "success": false,
  "message": "Reel not found"
}

// 403 - Private reel
{
  "success": false,
  "message": "This reel is private"
}
```

**Usage Notes:**
- Call this endpoint when user starts watching a reel
- Consider debouncing multiple calls from same user
- Recommended to implement client-side rate limiting

---

### 4. Get Reels by Blend

**Endpoint:** `GET /reels/blend/:blendId`

**Description:** Get all reels that feature a specific blend.

**Path Parameters:**
| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| blendId | string | Yes | Blend ID |

**Query Parameters:**
| Parameter | Type | Required | Default | Description |
|-----------|------|----------|---------|-------------|
| limit | number | No | 20 | Number of reels to return (max 50) |

**Example Request:**
```
GET /api/app/reels/blend/60f1b2e4d4b0f4001f5e4a3c?limit=10
```

**Success Response (200):**
```json
{
  "success": true,
  "message": "Reels by blend retrieved successfully",
  "data": {
    "reels": [
      {
        "id": "60f1b2e4d4b0f4001f5e4a3d",
        "caption": "Amazing multigrain blend recipe!",
        "poster_url": "https://bucket.s3.../poster.jpg",
        "video_url": "https://bucket.s3.../video.mp4",
        "duration": 45,
        "tags": ["healthy", "organic"],
        "views": 150,
        "createdAt": "2023-07-15T10:30:00.000Z",
        "createdBy": {
          "name": "Admin User"
        }
      }
    ],
    "blendId": "60f1b2e4d4b0f4001f5e4a3c"
  }
}
```

---

### 5. Search Reels

**Endpoint:** `GET /reels/search`

**Description:** Search reels by caption text or tags.

**Query Parameters:**
| Parameter | Type | Required | Default | Description |
|-----------|------|----------|---------|-------------|
| q | string | Yes | - | Search query (min 2 characters) |
| limit | number | No | 20 | Number of results (max 50) |

**Example Requests:**
```
GET /api/app/reels/search?q=healthy
GET /api/app/reels/search?q=multigrain&limit=10
GET /api/app/reels/search?q=organic%20wheat
```

**Success Response (200):**
```json
{
  "success": true,
  "message": "Search results retrieved successfully",
  "data": {
    "reels": [
      {
        "id": "60f1b2e4d4b0f4001f5e4a3d",
        "caption": "Healthy multigrain blend recipe!",
        "poster_url": "https://bucket.s3.../poster.jpg",
        "video_url": "https://bucket.s3.../video.mp4",
        "duration": 45,
        "tags": ["healthy", "organic", "multigrain"],
        "views": 150,
        "createdAt": "2023-07-15T10:30:00.000Z",
        "createdBy": {
          "name": "Admin User"
        },
        "blendSnapshot": {
          "name": "Multigrain Blend",
          "additives": [...],
          "price_per_kg": 52.5
        }
      }
    ],
    "searchQuery": "healthy",
    "count": 1
  }
}
```

**Error Responses:**
```json
// 400 - Query too short
{
  "success": false,
  "message": "Search query must be at least 2 characters"
}
```

**Search Features:**
- Case-insensitive search
- Searches in both caption and tags
- Results sorted by popularity (views) then recency
- Partial word matching supported

---

## Frontend Integration Examples

### React Hook for Reels Feed

```javascript
import { useState, useEffect, useCallback } from 'react';

export const useReelsFeed = (apiBaseUrl) => {
  const [reels, setReels] = useState([]);
  const [loading, setLoading] = useState(false);
  const [cursor, setCursor] = useState(null);
  const [hasMore, setHasMore] = useState(true);
  const [error, setError] = useState(null);

  const loadReels = useCallback(async (refresh = false) => {
    if (loading || (!hasMore && !refresh)) return;

    setLoading(true);
    setError(null);

    try {
      const params = new URLSearchParams({ limit: '20' });
      if (!refresh && cursor) {
        params.append('cursor', cursor);
      }

      const response = await fetch(`${apiBaseUrl}/app/reels?${params}`);
      const result = await response.json();

      if (!result.success) {
        throw new Error(result.message);
      }

      const newReels = result.data.reels;
      setReels(prev => refresh ? newReels : [...prev, ...newReels]);
      setCursor(result.data.nextCursor);
      setHasMore(result.data.hasMore);
    } catch (err) {
      setError(err.message);
    } finally {
      setLoading(false);
    }
  }, [apiBaseUrl, cursor, hasMore, loading]);

  const refresh = useCallback(() => {
    setCursor(null);
    setHasMore(true);
    loadReels(true);
  }, [loadReels]);

  useEffect(() => {
    loadReels(true);
  }, []);

  return {
    reels,
    loading,
    error,
    hasMore,
    loadMore: () => loadReels(false),
    refresh
  };
};
```

### Reel Player Component

```javascript
import React, { useState, useRef } from 'react';

const ReelPlayer = ({ reel, onView }) => {
  const [hasViewed, setHasViewed] = useState(false);
  const videoRef = useRef(null);

  const handlePlay = async () => {
    if (!hasViewed) {
      setHasViewed(true);
      try {
        await fetch(`/api/app/reels/${reel.id}/view`, {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: '{}'
        });
        onView?.(reel.id);
      } catch (error) {
        console.error('Failed to record view:', error);
      }
    }
  };

  return (
    <div className="reel-container">
      <video
        ref={videoRef}
        src={reel.video_url}
        poster={reel.poster_url}
        controls
        onPlay={handlePlay}
        className="reel-video"
      />
      
      <div className="reel-info">
        <h3>{reel.caption}</h3>
        
        <div className="reel-stats">
          <span>{reel.views} views</span>
          <span>{reel.formatted_duration}</span>
        </div>
        
        <div className="reel-tags">
          {reel.tags.map(tag => (
            <span key={tag} className="tag">#{tag}</span>
          ))}
        </div>
        
        {reel.blendDetails && (
          <BlendDetails blend={reel.blendDetails} />
        )}
      </div>
    </div>
  );
};

const BlendDetails = ({ blend }) => (
  <div className="blend-details">
    <h4>{blend.name}</h4>
    <div className="ingredients">
      {blend.ingredients.map((ingredient, index) => (
        <div key={index} className="ingredient">
          <span>{ingredient.name}</span>
          <span>{ingredient.percentage}%</span>
          <span>₹{ingredient.pricePerKg}/kg</span>
        </div>
      ))}
    </div>
    <div className="total-price">
      Total: ₹{blend.totalPricePerKg}/kg
    </div>
    <div className="share-code">
      Code: {blend.shareCode}
    </div>
  </div>
);
```

### Search Component

```javascript
import React, { useState, useEffect, useMemo } from 'react';
import { debounce } from 'lodash';

const ReelSearch = ({ apiBaseUrl, onResults }) => {
  const [query, setQuery] = useState('');
  const [results, setResults] = useState([]);
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState(null);

  const debouncedSearch = useMemo(
    () => debounce(async (searchQuery) => {
      if (searchQuery.length < 2) {
        setResults([]);
        return;
      }

      setLoading(true);
      setError(null);

      try {
        const params = new URLSearchParams({
          q: searchQuery,
          limit: '20'
        });

        const response = await fetch(`${apiBaseUrl}/app/reels/search?${params}`);
        const result = await response.json();

        if (!result.success) {
          throw new Error(result.message);
        }

        setResults(result.data.reels);
        onResults?.(result.data.reels, searchQuery);
      } catch (err) {
        setError(err.message);
        setResults([]);
      } finally {
        setLoading(false);
      }
    }, 300),
    [apiBaseUrl, onResults]
  );

  useEffect(() => {
    debouncedSearch(query);
    return () => debouncedSearch.cancel();
  }, [query, debouncedSearch]);

  return (
    <div className="reel-search">
      <input
        type="text"
        value={query}
        onChange={(e) => setQuery(e.target.value)}
        placeholder="Search reels..."
        className="search-input"
      />
      
      {loading && <div className="loading">Searching...</div>}
      {error && <div className="error">Error: {error}</div>}
      
      <div className="search-results">
        {results.map(reel => (
          <ReelCard key={reel.id} reel={reel} />
        ))}
      </div>
    </div>
  );
};
```

### Mobile-First Infinite Scroll

```javascript
import React, { useEffect, useCallback } from 'react';
import { useReelsFeed } from './hooks/useReelsFeed';

const MobileReelsFeed = () => {
  const { reels, loading, hasMore, loadMore } = useReelsFeed('/api');

  const handleScroll = useCallback(() => {
    if (
      window.innerHeight + document.documentElement.scrollTop
      >= document.documentElement.offsetHeight - 1000 // Load when 1000px from bottom
    ) {
      loadMore();
    }
  }, [loadMore]);

  useEffect(() => {
    window.addEventListener('scroll', handleScroll);
    return () => window.removeEventListener('scroll', handleScroll);
  }, [handleScroll]);

  return (
    <div className="mobile-reels-feed">
      {reels.map(reel => (
        <ReelPlayer key={reel.id} reel={reel} />
      ))}
      
      {loading && <div className="loading">Loading more reels...</div>}
      {!hasMore && <div className="end">No more reels to load</div>}
    </div>
  );
};
```

---

## Performance Optimization Tips

### Client-Side Caching
```javascript
// Cache reel details for better UX
const reelCache = new Map();

const getCachedReel = async (id) => {
  if (reelCache.has(id)) {
    return reelCache.get(id);
  }
  
  const response = await fetch(`/api/app/reels/${id}`);
  const result = await response.json();
  
  if (result.success) {
    reelCache.set(id, result.data.reel);
    return result.data.reel;
  }
  
  throw new Error(result.message);
};
```

### Lazy Loading Videos
```javascript
// Only load video when it comes into viewport
const LazyReelPlayer = ({ reel }) => {
  const [inView, setInView] = useState(false);
  const elementRef = useRef();

  useEffect(() => {
    const observer = new IntersectionObserver(
      ([entry]) => {
        if (entry.isIntersecting) {
          setInView(true);
          observer.disconnect();
        }
      },
      { threshold: 0.1 }
    );

    if (elementRef.current) {
      observer.observe(elementRef.current);
    }

    return () => observer.disconnect();
  }, []);

  return (
    <div ref={elementRef}>
      {inView ? (
        <video src={reel.video_url} poster={reel.poster_url} />
      ) : (
        <img src={reel.poster_url} alt="Video thumbnail" />
      )}
    </div>
  );
};
```

### Error Boundaries
```javascript
class ReelErrorBoundary extends React.Component {
  constructor(props) {
    super(props);
    this.state = { hasError: false, error: null };
  }

  static getDerivedStateFromError(error) {
    return { hasError: true, error };
  }

  componentDidCatch(error, errorInfo) {
    console.error('Reel component error:', error, errorInfo);
  }

  render() {
    if (this.state.hasError) {
      return (
        <div className="reel-error">
          <h3>Failed to load reel</h3>
          <button onClick={() => window.location.reload()}>
            Refresh Page
          </button>
        </div>
      );
    }

    return this.props.children;
  }
}
```

---

## Response Format Summary

All API responses follow this consistent format:

**Success Response:**
```json
{
  "success": true,
  "message": "Description of what happened",
  "data": {
    // Actual response data
  }
}
```

**Error Response:**
```json
{
  "success": false,
  "message": "Error description"
}
```

**HTTP Status Codes:**
- `200` - Success
- `400` - Bad Request (invalid parameters)
- `403` - Forbidden (private reel)
- `404` - Not Found
- `500` - Internal Server Error