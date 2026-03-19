import { test, expect } from '@playwright/test';

const API = 'http://localhost:8000';
const V1 = `${API}/api/v1`;
const LAT = 34.9003;
const LON = 33.6232;

test.describe('US-001: Health Check', () => {
  test('GET /health returns 200 with status ok', async ({ request }) => {
    const res = await request.get(`${API}/health`);
    expect(res.status()).toBe(200);
    const body = await res.json();
    expect(body.status).toBe('ok');
  });
});

test.describe('US-002: Nearby Places Search', () => {
  test('returns places sorted by distance', async ({ request }) => {
    const res = await request.get(`${V1}/places`, { params: { lat: LAT, lon: LON, radius: 50000 } });
    expect(res.status()).toBe(200);
    const body = await res.json();
    expect(body).toHaveProperty('places');
    expect(body).toHaveProperty('total');
    expect(body.places.length).toBeGreaterThan(0);
    for (const place of body.places.slice(0, 5)) {
      expect(place).toHaveProperty('id');
      expect(place).toHaveProperty('name');
      expect(place).toHaveProperty('distance_m');
    }
    for (let i = 1; i < Math.min(body.places.length, 10); i++) {
      expect(body.places[i].distance_m).toBeGreaterThanOrEqual(body.places[i - 1].distance_m);
    }
  });

  test('returns empty for remote location', async ({ request }) => {
    const res = await request.get(`${V1}/places`, { params: { lat: 0, lon: 0, radius: 1000 } });
    expect(res.status()).toBe(200);
    const body = await res.json();
    expect(body.places).toHaveLength(0);
  });

  test('validates latitude range', async ({ request }) => {
    const res = await request.get(`${V1}/places`, { params: { lat: 100, lon: LON, radius: 10000 } });
    expect(res.status()).toBe(422);
  });

  test('validates longitude range', async ({ request }) => {
    const res = await request.get(`${V1}/places`, { params: { lat: LAT, lon: 200, radius: 10000 } });
    expect(res.status()).toBe(422);
  });

  test('validates radius range', async ({ request }) => {
    const res = await request.get(`${V1}/places`, { params: { lat: LAT, lon: LON, radius: 0 } });
    expect(res.status()).toBe(422);
  });
});

test.describe('US-003: Category Filter', () => {
  test('filters by category slug', async ({ request }) => {
    const res = await request.get(`${V1}/places`, { params: { lat: 35.1856, lon: 33.3823, radius: 50000, category: 'park' } });
    expect(res.status()).toBe(200);
    const body = await res.json();
    expect(body.places.length).toBeGreaterThan(0);
    for (const place of body.places) { expect(place.category).toBe('park'); }
  });

  test('returns empty for non-existent category', async ({ request }) => {
    const res = await request.get(`${V1}/places`, { params: { lat: LAT, lon: LON, radius: 50000, category: 'nonexistent' } });
    expect(res.status()).toBe(200);
    const body = await res.json();
    expect(body.places).toHaveLength(0);
  });
});

test.describe('US-004: Age Group Filter', () => {
  test('filters by toddler age group', async ({ request }) => {
    const res = await request.get(`${V1}/places`, { params: { lat: LAT, lon: LON, radius: 50000, age_group: 'toddler' } });
    expect(res.status()).toBe(200);
    const body = await res.json();
    for (const place of body.places) {
      expect(place.age_min).toBeLessThanOrEqual(3);
      expect(place.age_max).toBeGreaterThanOrEqual(1);
    }
  });

  test('accepts all age groups', async ({ request }) => {
    for (const age of ['infant', 'toddler', 'preschool', 'school_age']) {
      const res = await request.get(`${V1}/places`, { params: { lat: LAT, lon: LON, radius: 50000, age_group: age } });
      expect(res.status()).toBe(200);
    }
  });
});

test.describe('US-005: Text Search', () => {
  test('searches by name keyword', async ({ request }) => {
    const res = await request.get(`${V1}/places`, { params: { lat: 35.1856, lon: 33.3823, radius: 50000, q: 'museum' } });
    expect(res.status()).toBe(200);
    const body = await res.json();
    expect(body.places.length).toBeGreaterThan(0);
    const hasMatch = body.places.some((p: any) => p.name.toLowerCase().includes('museum'));
    expect(hasMatch).toBeTruthy();
  });

  test('returns empty for nonsense query', async ({ request }) => {
    const res = await request.get(`${V1}/places`, { params: { lat: LAT, lon: LON, radius: 50000, q: 'xyznonexistent123' } });
    expect(res.status()).toBe(200);
    const body = await res.json();
    expect(body.places).toHaveLength(0);
  });
});

test.describe('US-006: Place Detail', () => {
  test('returns full place details by ID', async ({ request }) => {
    const listRes = await request.get(`${V1}/places`, { params: { lat: 35.1856, lon: 33.3823, radius: 50000, limit: 1 } });
    const listBody = await listRes.json();
    expect(listBody.places.length).toBeGreaterThan(0);
    const placeId = listBody.places[0].id;
    const res = await request.get(`${V1}/places/${placeId}`);
    expect(res.status()).toBe(200);
    const place = await res.json();
    expect(place.id).toBe(placeId);
    expect(place).toHaveProperty('name');
    expect(place).toHaveProperty('amenities');
    expect(place).toHaveProperty('is_indoor');
  });

  test('returns 404 for non-existent place', async ({ request }) => {
    const res = await request.get(`${V1}/places/999999`);
    expect(res.status()).toBe(404);
  });
});

test.describe('US-007: Trilingual Support', () => {
  test('accepts all 3 languages', async ({ request }) => {
    for (const lang of ['en', 'el', 'ru']) {
      const res = await request.get(`${V1}/places`, { params: { lat: LAT, lon: LON, radius: 50000, lang } });
      expect(res.status()).toBe(200);
    }
  });

  test('rejects invalid language', async ({ request }) => {
    const res = await request.get(`${V1}/places`, { params: { lat: LAT, lon: LON, radius: 50000, lang: 'xx' } });
    expect(res.status()).toBe(422);
  });

  test('categories return translated names', async ({ request }) => {
    const enRes = await request.get(`${V1}/categories`, { params: { lang: 'en' } });
    const elRes = await request.get(`${V1}/categories`, { params: { lang: 'el' } });
    const enData = await enRes.json();
    const elData = await elRes.json();
    const enNames = enData.categories.map((c: any) => c.name);
    const elNames = elData.categories.map((c: any) => c.name);
    expect(enNames.some((n: string, i: number) => n !== elNames[i])).toBeTruthy();
  });
});

test.describe('US-008: Weather Data', () => {
  test('returns weather response', async ({ request }) => {
    const res = await request.get(`${V1}/weather`, { params: { lat: LAT, lon: LON } });
    expect([200, 502, 503]).toContain(res.status());
    if (res.status() === 200) {
      const data = await res.json();
      expect(data).toHaveProperty('weather_mode');
      expect(['outdoor', 'indoor', 'caution']).toContain(data.weather_mode);
    }
  });
});

test.describe('US-009: Categories', () => {
  test('returns all 23 categories', async ({ request }) => {
    const res = await request.get(`${V1}/categories`);
    expect(res.status()).toBe(200);
    const data = await res.json();
    expect(data.total).toBe(23);
    expect(data.categories).toHaveLength(23);
    for (const cat of data.categories) {
      expect(cat).toHaveProperty('id');
      expect(cat).toHaveProperty('slug');
      expect(cat).toHaveProperty('name');
    }
  });

  test('categories are cached', async ({ request }) => {
    await request.get(`${V1}/categories`);
    const start = Date.now();
    const res = await request.get(`${V1}/categories`);
    expect(res.status()).toBe(200);
    expect(Date.now() - start).toBeLessThan(500);
  });
});

test.describe('US-010: Events', () => {
  test('returns events response', async ({ request }) => {
    const res = await request.get(`${V1}/events`, { params: { lat: LAT, lon: LON, radius: 50000 } });
    expect(res.status()).toBe(200);
    const body = await res.json();
    expect(body).toHaveProperty('events');
    expect(body).toHaveProperty('total');
    expect(Array.isArray(body.events)).toBeTruthy();
  });
});

test.describe('US-012: Pagination', () => {
  test('respects limit parameter', async ({ request }) => {
    const res = await request.get(`${V1}/places`, { params: { lat: 35.1856, lon: 33.3823, radius: 50000, limit: 3 } });
    expect(res.status()).toBe(200);
    const body = await res.json();
    expect(body.places.length).toBeLessThanOrEqual(3);
  });

  test('offset returns different results', async ({ request }) => {
    const p1 = await (await request.get(`${V1}/places`, { params: { lat: 35.1856, lon: 33.3823, radius: 50000, limit: 5, offset: 0 } })).json();
    const p2 = await (await request.get(`${V1}/places`, { params: { lat: 35.1856, lon: 33.3823, radius: 50000, limit: 5, offset: 5 } })).json();
    if (p2.places.length > 0) {
      const ids1 = new Set(p1.places.map((p: any) => p.id));
      for (const p of p2.places) { expect(ids1.has(p.id)).toBeFalsy(); }
    }
  });

  test('rejects negative offset', async ({ request }) => {
    const res = await request.get(`${V1}/places`, { params: { lat: LAT, lon: LON, radius: 10000, offset: -1 } });
    expect(res.status()).toBe(422);
  });

  test('rejects zero limit', async ({ request }) => {
    const res = await request.get(`${V1}/places`, { params: { lat: LAT, lon: LON, radius: 10000, limit: 0 } });
    expect(res.status()).toBe(422);
  });
});

test.describe('Photo Proxy', () => {
  test('returns 503 when Google API key is not set', async ({ request }) => {
    const res = await request.get(`${V1}/photos/fake_reference`);
    expect(res.status()).toBe(503);
  });
});

test.describe('Event Sub-Types', () => {
  test('filters by cinema type', async ({ request }) => {
    const res = await request.get(`${V1}/events`, {
      params: { lat: LAT, lon: LON, radius: 50000, event_type: 'cinema' }
    });
    expect(res.status()).toBe(200);
    const body = await res.json();
    for (const event of body.events) {
      expect(event.event_type).toBe('cinema');
    }
  });

  test('filters by theatre type', async ({ request }) => {
    const res = await request.get(`${V1}/events`, {
      params: { lat: LAT, lon: LON, radius: 50000, event_type: 'theatre' }
    });
    expect(res.status()).toBe(200);
  });

  test('returns event_type field in response', async ({ request }) => {
    const res = await request.get(`${V1}/events`, {
      params: { lat: LAT, lon: LON, radius: 50000 }
    });
    expect(res.status()).toBe(200);
    const body = await res.json();
    for (const event of body.events) {
      expect(event).toHaveProperty('event_type');
    }
  });
});

test.describe('Input Validation', () => {
  test('rejects missing lat/lon', async ({ request }) => {
    const res = await request.get(`${V1}/places`);
    expect(res.status()).toBe(422);
  });
  test('rejects missing lat', async ({ request }) => {
    const res = await request.get(`${V1}/places`, { params: { lon: LON } });
    expect(res.status()).toBe(422);
  });
  test('rejects missing lon', async ({ request }) => {
    const res = await request.get(`${V1}/places`, { params: { lat: LAT } });
    expect(res.status()).toBe(422);
  });
});
