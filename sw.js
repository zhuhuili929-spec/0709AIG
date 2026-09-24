const CACHE_NAME = 'tableware-vision-v2';
const APP_SHELL = [
  './', './index.html', './manifest.webmanifest', './icon.svg',
  './案例图/拍照优秀案例碗3.jpg', './案例图/拍照优秀案例碗2.jpg', './案例图/拍照优秀案例碗1.jpg',
  './案例图/拍照优秀案例海鲜盘 (2).jpg', './案例图/拍照优秀案例海鲜盘 (1).jpg',
  './案例图/拍照优秀案例异形盘 (2).jpg', './案例图/拍照优秀案例异形盘 (1).jpg',
  './案例图/拍照优秀案例1.png', './案例图/拍照优秀案例.png', './案例图/sku.jpg',
  './案例图/拍照好的案例组合套系餐具 (3).jpg', './案例图/拍照好的案例组合套系餐具 (2).jpg', './案例图/拍照好的案例组合套系餐具 (1).jpg',
  './案例图/拍照好的案例火锅盘 (2).jpg', './案例图/拍照好的案例火锅盘 (1).jpg', './案例图/拍照好的案例场景图.jpg',
  './案例图/拍照好的案例龙虾盘 (3).jpg', './案例图/拍照好的案例龙虾盘 (2).jpg', './案例图/拍照好的案例龙虾盘 (1).jpg',
  './案例图/组合拍照优秀案例 (1).jpg', './案例图/盘子sku.jpg', './案例图/组合拍照优秀案例 (2).jpg',
  './案例图/餐具组合拍照 (3).jpg', './案例图/餐具组合拍照 (2).jpg', './案例图/餐具组合拍照 (1).jpg',
  './案例图/餐具组合 (2).jpg', './案例图/餐具组合 (1).jpg', './案例图/面碗sku.jpg',
  './案例图/销量好的主图案例碗 (4).jpg', './案例图/销量好的主图案例碗 (3).jpg', './案例图/销量好的主图案例碗 (2).jpg', './案例图/销量好的主图案例碗 (1).jpg',
  './案例图/销量好的主图案例 盘子 (4).jpg', './案例图/销量好的主图案例 盘子 (3).jpg', './案例图/销量好的主图案例 盘子 (2).jpg', './案例图/销量好的主图案例 盘子 (1).jpg',
  './案例图/详情案例.jpg', './案例图/详情案例 (2).jpg', './案例图/详情案例 (1).jpg'
];

self.addEventListener('install', event => {
  event.waitUntil(caches.open(CACHE_NAME).then(cache => cache.addAll(APP_SHELL)));
  self.skipWaiting();
});

self.addEventListener('activate', event => {
  event.waitUntil(caches.keys().then(keys => Promise.all(keys.filter(key => key !== CACHE_NAME).map(key => caches.delete(key)))));
  self.clients.claim();
});

self.addEventListener('fetch', event => {
  const request = event.request;
  if (request.method !== 'GET' || new URL(request.url).origin !== self.location.origin) return;
  const isPage = request.mode === 'navigate' || request.destination === 'document';
  event.respondWith((isPage ? fetch(request).then(response => {
    const copy = response.clone();
    caches.open(CACHE_NAME).then(cache => cache.put(request, copy));
    return response;
  }) : caches.match(request).then(cached => cached || fetch(request).then(response => {
    const copy = response.clone();
    caches.open(CACHE_NAME).then(cache => cache.put(request, copy));
    return response;
  }))).catch(() => caches.match(request).then(cached => cached || caches.match('./index.html'))));
});
