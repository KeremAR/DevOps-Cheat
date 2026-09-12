### Web Rendering Mimarileri ve Modern Frontend Yaklaşımları

---

### 1. Temel Rendering Yöntemleri

* **SSR (Server-Side Rendering):** Kullanıcı siteye her tıkladığında (Request anında) HTML sunucuda canlı olarak üretilir. Normalde browser'da çalışan o JavaScript kodu (React/Svelte bileşenleriniz), browser'a hiç gelmeden önce sunucudaki Node.js içinde çalışır. Node.js veriyi çeker, HTML'i üretir ve browser'a içi doldurulmuş hazır HTML gönderir.
* **CSR (Client-Side Rendering):** HTML tarayıcıda (Browser anında) JavaScript çalıştırılarak üretilir. Sunucu size içi boş bir HTML verir (`<div id="root"></div>`). Browser o boş sayfayı indirir, JavaScript'i çalıştırır, API'ye gidip veriyi çeker ve HTML'i browser'ın kendi içinde üretir.
* **SSG (Static Site Generation):** HTML sayfaları site henüz yayınlanmadan önce (Build / Derleme anında) topluca üretilir ve hazır dosya (`.html`) olarak sunucuya koyulur.
* **ISR (Incremental Static Regeneration):** Siteniz statiktir (SSG). Ancak arka tarafta "Bu sayfa her veri değiştiğinde veya 60 saniyede bir arka planda kendini yenilesin" dersiniz. Kısaca özetlemek gerekirse SSG (Statik Site) ile SSR (Dinamik Sunucu) dünyalarının en güçlü yönlerini birleştiren hibrit bir rendering mimarisidir.
* **PPR (Partial Prerendering - Kısmi Ön Derleme):** Next.js'in SSG/ISR'ın hızı ile SSR'ın canlılığını aynı HTML sayfasında birleştiren en yeni hibrit render mimarisidir. Sayfayı ikiye böler: Herkes için aynı olan kısımları statik kabuk (CDN) olarak tutar, kişiye özel/dinamik kısımları ise sunucudan paralel olarak akar (Stream).

---

### 2. Hangi Senaryoda Hangi Yöntem Gerekli?

#### 1. CSR (Client-Side Rendering) – React + Vite

* **Ne Zaman Gerekli?** Sayfanın Google'da çıkması (SEO) gerekmiyorsa, kullanıcı girişi (login) arkasında çalışan bir sistemse.
* **Hangi Projelerde?** Admin Panelleri, Yönetim Dashboard'ları, CRM sistemleri, Trello/Slack benzeri iç araçlar, E-posta istemcileri.
* **Neden?** Sunucu maliyeti sıfıra yakındır (statik sunulur), açıldıktan sonra uygulama gibi çok akıcı çalışır.

#### 2. SSR (Server-Side Rendering) – Next.js / SvelteKit

* **Ne Zaman Gerekli?** Sayfadaki veri kişiye özeldir veya anlık değişir, AMA aynı zamanda SEO ve ilk açılış hızı hayati önem taşır.
* **Hangi Projelerde?** Sahibinden/Zillow benzeri Emlak & İlan siteleri, Canlı Borsa/Finans sayfaları, Twitter/X gibi anlık akış sayfaları, Kişiselleştirilmiş kullanıcı profilleri.
* **Neden?** Google botları sayfaya geldiğinde dolu HTML görür (SEO mükemmeldir), kullanıcı her tıkladığında en güncel canlı veriyi alır.

#### 3. SSG (Static Site Generation) – Astro / Hugo / SvelteKit SSG

* **Ne Zaman Gerekli?** Sitedeki içerik herkes için aynıysa ve sık sık değişmiyorsa.
* **Hangi Projelerde?** Kişisel Bloglar, Portföy Siteleri, Şirket Tanıtım / Landing Page sayfaları, Yazılım Dokümantasyon siteleri (Örn: React/Vue resmi dokümanları).
* **Neden?** Dünyanın en hızlı yüklenen web siteleridir, sunucu çökmeleri yaşanmaz, CDN üzerinden ücretsiz/çok ucuza sunulur. SEO için mükemmeldir.

#### 4. ISR (Incremental Static Regeneration) – Next.js / SvelteKit (ISR)

* **Ne Zaman Gerekli?** Sitede on binlerce sayfa varsa (SSG ile derlemek imkansızsa) ama veri her saniye değişmiyorsa (her kullanıcı için özel SSR yapıp sunucuyu yormak istemiyorsanız).
* **Hangi Projelerde?** Trendyol/Amazon benzeri dev E-Ticaret siteleri (Ürün detay sayfaları), Ekşi Sözlük / Reddit benzeri dev forum ve içerik siteleri, Film/Dizi veritabanı siteleri (IMDb).
* **Neden?** SSG'nin ışık hızını ve düşük sunucu maliyetini sunar; aynı zamanda veriler arka planda periyodik olarak kendi kendini günceller.

#### 5. PPR (Partial Prerendering) – Next.js (App Router)

* **Ne Zaman Gerekli?** Sayfada hem herkes için ortak olan devasa bir statik yapı hem de o sayfaya giren kişiye özel (sepet durumu, izleme bilgisi, beğeni) anlık veriler aynı anda bulunuyorsa.
* **Hangi Projelerde?** TV Time / Letterboxd benzeri dizi/film detay sayfaları (Dizi bilgisi statik, bölümün izlenme tikleri kişiye özel), Kullanıcıya özel dinamik banner barındıran E-ticaret ana sayfaları.
* **Neden?** Kullanıcı sayfaya girdiğinde statik kabuk CDN'den 0ms'de anında açılır; dinamik yerler sunucu arka planda veriyi çektikçe ekrana akar (Streaming). Sayfanın tamamı için SSR yükü çekilmez.

---

### 3. Rendering Yöntemlerinin Karşılaştırması

| Özellik | SSG (Static Site Gen.) | ISR (Incremental Static) | SSR (Server-Side) | PPR (Partial Prerender) | CSR (Client-Side) |
| --- | --- | --- | --- | --- | --- |
| **HTML Ne Zaman Üretilir?** | Derleme anında (Build time) | Build time + Arka planda periyodik | İstek anında (Request time) | Statik kısım Build'de, Dinamik kısım Request'te | Tarayıcıda (Run time) |
| **Sunucu Yükü & Maliyet** | Neredeyse sıfır. Sadece dosya sunar. | Çok düşük. Sadece süre doldukça re-render eder. | Yüksek. Her istekte sunucu CPU/RAM harcar. | Düşük-Orta. Sadece dinamik delikler için sunucu çalışır. | Düşük. Yük kullanıcının cihazındadır. |
| **Açılış Hızı (TTFB / FCP)** | Işık hızında. En hızlı yöntemdir. | Işık hızında (Statik HTML sunulur). | Sunucunun hızına ve DB sorgusuna bağlıdır. | Işık hızında (Kabuk anında gelir, delikler dolar). | Yavaş. JS indirilir, çalışır, veri çekilir. |
| **Dinamik Veri Uygunluğu** | Kötü. Veri değişirse siteyi tekrar build etmek gerekir. | Orta-İyi. Belirlenen periyotlarda güncellenir. | Mükemmel. Her istekte en güncel veri gelir. | Mükemmel. Statik kabuk içinde canlı veri sunulabilir. | İyi. Sayfa açıldıktan sonra API'den çekilir. |

---

### 4. ISR ve PPR'ın Derinlemesine Çalışma Mantıkları

#### ISR (Incremental Static Regeneration)

Tam olarak çözdüğü sorun şudur: SSG inanılmaz hızlıdır ve sunucu maliyeti sıfıra yakındır. Ancak 10.000 ürünlü bir e-ticaret siteniz varsa, tek bir ürünün fiyatı değiştiğinde tüm siteyi baştan derlemek (`npm run build`) saatler sürebilir. ISR, tüm siteyi baştan derlemeden tek bir sayfayı arka planda statik olarak yeniden üretmenizi sağlar.

**ISR Nasıl Çalışır? (Stale-While-Revalidate Mantığı)**

1. **İlk Derleme (Build):** Sitenizi build ettiğinizde sadece kritik sayfalar (örneğin popüler 100 ürün) statik HTML olarak üretilir.
2. **Kullanıcı İsteği (Stale Data):** Bir kullanıcı statik olarak üretilmiş sayfaya girer. Sayfa milisaniyeler içinde (SSG hızında) açılır.
3. **Süre Kontrolü (Revalidation):** Sayfaya tanımladığınız süre (örneğin `revalidate: 60` saniye) dolmuşsa, sunucu kullanıcıya var olan (eski) statik sayfayı göstermeye devam ederken arka planda (background) sadece o sayfanın verisini veritabanından çeker ve yeni statik HTML'i üretir.
4. **Güncelleme:** Sayfayı ziyaret eden bir sonraki kullanıcı, arka planda taze üretilmiş yeni statik HTML'i görür.

Böylece kullanıcı hiçbir zaman sunucunun veritabanı sorgusu yapmasını veya sayfayı üretmesini beklemez; her zaman hazır statik HTML alır.

> **Önemli Not:** ISR yapabilmek için arka planda çalışan ve istekleri karşılayan bir Node.js sunucusu (Server) veya bir Edge Runtime gerekir. Sayfayı ilk başta statik sunsa bile, arka planda süre dolduğunda veritabanına bağlanıp yeni HTML'i yeniden derleyecek bir sunucu şarttır.

#### PPR (Partial Prerendering)

PPR Hangi Problemi Çözer? Eskiden (veya klasik Next.js'te) bir sayfa için iki seçeneğiniz vardı:

* Ya sayfanın tamamını SSG/ISR yaparsınız: Sayfa CDN'den ışık hızında açılır ama kullanıcıya özel canlı verileri (örn: profil resmi, sepet, izleme durumu) ilk açılışta gösteremezsiniz.
* Ya da sayfanın tamamını SSR yaparsınız: Kullanıcıya özel verileri gösterirsiniz ama sunucu veritabanına sorgu atıp tüm sayfayı üretene kadar ekran bekler (yavaş LCP).

PPR bu zorunlu tercihi ortadan kaldırır. Tek bir rotayı iki parçaya böler:

1. **Statik Kabuk (Static Shell):** Sayfanın kişiye özel olmayan, herkes için aynı olan kısımları (Başlık, Dizi Künyesi, Resimler, Düzen). Bu kısım build anında veya ISR ile önceden derlenip CDN'e koyulur.
2. **Dinamik Delikler (Dynamic Holes):** Kişiye özel veya anlık veritabanı sorgusu gerektiren kısımlar (Örn: "Bu bölümü izledin mi?" butonu, bildirimler).

---

### 5. Single Page Application (SPA) ve Çalışma Yapısı

Geleneksel bir web sitesinde (MPA - Multi Page Application) veya klasik SSR sitesinde, menüdeki başka bir sayfaya (`/hakkimizda`, `/iletisim`) tıkladığınızda:

1. Tarayıcı sunucuya yeni bir HTTP isteği atar.
2. Sayfa beyazlar, yükleme ikonu döner.
3. Sunucudan yeni bir HTML dosyası gelir ve ekran tamamen yenilenir.

**SPA Mimarisinde İse:**

1. Kullanıcı siteye girdiğinde sunucudan tek bir boş HTML dosyası (`index.html`) ve uygulamanın tüm JavaScript kodları çekilir.
2. Kullanıcı site içinde gezinirken (örneğin `/profil` veya `/ayarlar` sayfasına tıkladığında) sayfa asla yeniden yüklenmez (refresh olmaz).
3. JavaScript, tarayıcının adres çubuğundaki URL'i günceller ve sunucudan HTML istemek yerine sadece değişmesi gereken JSON verisini (API üzerinden) çeker.
4. Sayfadaki ilgili bölümü (DOM) anında günceller.

**Günlük Hayattan SPA Örnekleri:**

* **Gmail:** E-postalarınız arasında gezinirken, bir e-postayı açtığınızda veya silerken sayfa hiç beyazlayıp baştan yüklenir mi? Hayır. Sadece orta kısımdaki içerik değişir.
* **Spotify Web:** Müzik çalarken sol menüden başka bir çalma listesine geçseniz bile alttaki şarkı çalmaya devam eder. Sayfa yeniden yüklenmediği için müzik kesilmez.

#### React + Vite Neden SPA'dır?

React + Vite kombinasyonunda durum Next.js veya Nuxt gibi sunucu taraflı (SSR/ISR) framework'lerden tamamen farklıdır. Çünkü Vite bir "Full-Stack Framework" değil, bir "Build Tool" (Derleme / Geliştirme Aracı) dır. React + Vite ile oluşturduğunuz standart bir proje varsayılan olarak %100 saf bir Client-Side Rendering (CSR / SPA) uygulamasıdır.

---

### 6. Framework ve Caching Mimairilerinin Kıyaslaması

#### Framework Kıyaslaması (Vite vs Next.js vs SvelteKit)

| Özellik | React + Vite (SPA) | Next.js (React Framework) | SvelteKit (Svelte Framework) |
| --- | --- | --- | --- |
| **Varsayılan Mimari** | CSR (Client-Side Rendering) | Hybrid (SSR + SSG + ISR + PPR + CSR) | Hybrid (SSR + SSG + ISR + CSR) |
| **ISR / SSG / SSR Desteği** | Yok (Manuel eklenti/CDN ile simüle edilir) | Yerleşik Var (`revalidate` / `fetch` / `App Router`) | Yerleşik Var (`adapter-static` / `prerender`) |
| **Sunucu (Server) İhtiyacı** | Yok (Sadece statik dosya sunucusu/Nginx yeterli) | Var (Node.js runtime veya Serverless) | Var (Node.js runtime veya Serverless) |
| **Derleme Mantığı** | Virtual DOM (JS) | Virtual DOM (JS) | Compiler (Saf JS çıktısı) |
| **JS Paket Boyutu** | Orta / Büyük | Büyük | Çok Küçük (Daha hızlı açılış) |

#### Cache Kıyaslaması: ISR (Server-Side) vs TanStack Query / SWR (Client-Side)

| Özellik | ISR (Server-Side Cache) | TanStack Query / SWR (Client-Side Cache) |
| --- | --- | --- |
| **Cache Nerede Durur?** | Sunucuda / CDN Ağında | Kullanıcının Tarayıcısında (RAM / LocalStorage) |
| **Kullanıcılar Arası Paylaşılır mı?** | **EVET.** Ahmet'in oluşturduğu cache'i Mehmet de kullanır. | **HAYIR.** Her kullanıcının cache'i tamamen kendinedir. |
| **İlk Defa Giren Kullanıcı Bekler mi?** | **HAYIR.** Sunucuda HTML hazır olduğu için 0ms'de açılır. | **EVET.** Sayfa ilk açıldığında cache boş olduğu için API'yi bekler. |
| **İdeal Olduğu Veri Türü** | Herkes için ortak olan veri (Dizi adı, afişi, konusu, oyuncuları). | Kişiye özel olan veri (Kullanıcının izlediği bölümler, verdiği puan). |

#### Client-Side Cache (TanStack Query/SWR) Veriyi Nerede Tutuyor? Browser Kapanırsa Gitmez mi?

* **Varsayılan Durum (RAM Cache):** SWR veya TanStack Query veriyi JavaScript belleğinde tutar. Sayfalar arası gezinirken (örneğin `/diziler` sayfasından `/profil` sayfasına geçip geri geldiğinizde) sayfa hiç yenilenmediği için veri RAM'den 0 milisaniyede anında gelir. Ancak tarayıcı sekmesini kapatırsanız veya F5 atarsanız bu RAM temizlenir.
* **Kalıcı Durum (Persist Cache):** Eğer "Sayfa kapansa veya kullanıcı F5 atsa bile veri gitmesin" isterseniz, TanStack Query/SWR kütüphanelerine tek satırlık bir eklenti (`persistQueryClient` veya `localStorage` entegrasyonu) yaparsınız. Bu durumda veri tarayıcının `LocalStorage` veya `IndexedDB` alanına yazılır. Sayfayı kapatıp 3 gün sonra açsanız bile veri ilk olarak oradan anında okunur, ardından arka planda API'den tazelenir.

---

### 7. Hydration ve Qwik Resumability Mimari Karşılaştırması

#### 1. Hydration (Nemlendirme / Canlandırma) Nedir?

Hydration, sunucuda HTML olarak üretilmiş "kuru" ve statik bir web sayfasının, tarayıcıya ulaştıktan sonra JavaScript yüklenerek canlı ve etkileşimli (interaktif) hale getirilmesi sürecidir.

**Nasıl Çalışır?**

1. **Sunucu Tarafı (SSR/SSG):** Sunucu, JavaScript kodunu çalıştırır ve tarayıcıya sadece saf HTML/CSS gönderir.
2. **İlk Görüntü (Fast FCP):** Kullanıcı sayfayı anında görür (HTML render olduğu için), ancak butona tıklasa da henüz çalışmaz. Sayfa "kuru" bir maket gibidir.
3. **Hydration Adımı:** Tarayıcı, ilgili JavaScript paketini indirir. React/Vue/Svelte gibi kütüphaneler ekrandaki DOM elemanları ile indirdiği JS kodunu eşleştirir, olay dinleyicilerini (click, hover vb.) butonlara bağlar.
4. **Canlı Sayfa:** Sayfa artık tamamen etkileşimli hale gelir ("nemlenmiştir").

#### 2. Astro vs Qwik: "Adalar Mimarisi" ve "Resumability"

Qwik, Hydration mantığını ortadan kaldırıp yerine Resumability (Devam Edilebilirlik) adını verdiği yepyeni bir mimari getirmiştir.

##### Senaryo 1: Dışarıdan Hiç Kütüphane (React/Vue) Kullanmıyoruz

* **Astro:** Siz Astro'nun kendi bileşeniyle (`.astro` dosyası) interaktif bir şey yazmak istediğinizde, bileşenin içine klasik `<script>` etiketi koyarsınız. Astro bunu saf Vanilla JS (DOM manipulation) olarak tarayıcıya basar. Yani Astro'nun kendi içinde declarative (React gibi `useState` mantığında) bir state engine'i yoktur.
* **Qwik:** Qwik'in kendi öz bileşen dili (`component$`) vardır. React yazarmış gibi `useSignal()` (state), `onClick$` yazarsınız. Qwik 0 KB JS indirir. Kullanıcı tıklayınca o 1 KB'lık Qwik kodunu indirip çalıştırır (Resumability).
* **Ayrım:** Dış kütüphane yokken Astro bir "Statik HTML / Multi-Page App (MPA) üreticisi"dir. Qwik ise kendisi "Hydration'sız çalışan bir React alternatifi"dir.

##### Senaryo 2: Araya React Sokuyoruz (`client:` vs `qwikify$`)

* **Astro + React:** `<ReactComponent client:visible/>` yazarsanız $\rightarrow$ Astro bir Ada (Island) oluşturur. O ada için React JS indirilir ve Hydrate edilir.
* **Qwik + React:** `qwikify$(ReactComponent, { clientOnly: true })` yazarsanız $\rightarrow$ Qwik bir Ada (Island) oluşturur. O ada için React JS indirilir ve Hydrate edilir.

Yani Qwik'e React soktuğunuz an, Qwik Resumability özelliğini o bileşen için iptal eder ve tıpkı Astro gibi bir Adalar Mimarisine (Islands Architecture) dönüşür.

##### Büyük Özet:

* **Astro:** Doğuştan bir Toplayıcıdır (Orchestrator). Kendi dahili karmaşık state/component motoru yoktur. Amacı HTML basmak, interaktif yerleri React/Svelte/Vue adalarına devretmektir.
* **Qwik:** Doğuştan bir UI Framework'üdür (React Alternatifi). Kendi bileşen motoru vardır. Amacı React'in yaptığı her şeyi (state, JSX, bileşen yapısı) yapıp, React'in Hydration yükünü ortadan kaldırmaktır.
* **"Islands" (Adalar):** Farklı kütüphaneleri (React/Svelte) bir sayfada toplayıp isolated (izole) şekilde hydrate etme tekniğidir. (Astro'nun ana olayıdır, Qwik ise `qwikify$` ile bunu taklit eder).
* **"Resumability":** Bir UI framework'ünün (Qwik) kendi JSX bileşenlerini hydrate etmeden çalıştırma metodudur. (Astro bunu yapamaz, çünkü Astro'nun Qwik gibi bir JSX/state motoru yoktur).

#### 3. Hydration ve Resumability Arasındaki Temel Fark

> ISR, sunucuda veya CDN'de kullanıcıya gönderilecek HTML dosyasının ne zaman ve nasıl hazırlanacağıyla ilgilenir. Hydration veya Qwik'in Resumability'si ise o HTML tarayıcıya indikten sonra içindeki butonların nasıl tıklanabilir hale geleceğiyle ilgilenir.

* **Hydration:** Sayfa açılır açılmaz 100 butonun da JavaScript kodu tarayıcıya iner ve 100 buton da belleğe taranıp bağlanır. (Siz hiçbirine tıklamasanız bile!)
* **Resumability:** Sayfa açıldığında 0 KB JS iner. Siz 47. butona tıkladığınız an, sadece o 47. butonun 1 KB'lık JS kodu indirilir ve çalışır. Kalan 99 butonun JS'i internet ağından bile geçmez.

#### 4. Qwik'in En Büyük Eksileri ve Riskleri

1. **İlk Etkileşimde Ağ Gecikmesi (Network Waterfall / Latency):** Qwik, tıklama anında ilgili JavaScript parçasını indirir. Eğer kullanıcının interneti yavaşsa veya mobil bağlantısı dalgalanıyorsa butonun yanıt vermesinde milisaniyelik gecikme hissedilebilir.
2. **Kütüphane ve Ekosistem Kısırlaştırması (En Büyük Problem):** React'te npm'den tek komutla kuracağınız binlerce olgun kütüphane varken, Qwik uyumlu native kütüphane sayısı son derece sınırlıdır. Qwik `qwikify$` ambalajıyla React bileşenlerini çalıştırmanıza izin verir; ancak bir React kütüphanesini Qwik içine koyduğunuz an React'in tüm Hydration yükünü projeye sokmuş olursunuz. Qwik'in o "sıfır JS" büyüsü anında bozulur.

---

### 8. Modern Full-Stack Sunucu ve Dağıtım (Deployment) Mantığı

Eski geleneksel sitelerde "Frontend" demek, bir klasör dolusu statik `index.html`, `style.css` ve `script.js` dosyasından ibaretti. Bunları Nginx sunucusuna koyardınız, biterdi.

Ancak Astro (SSR modında), Next.js veya SvelteKit kullandığınızda "Frontend" kavramı artık sadece statik bir dosya değildir; Frontend'inizin içinde küçük bir Node.js / Edge Runtime sunucusu çalışır.

Siz Frontend projenizi Vercel, Cloudflare Pages veya Netlify'a yüklediğinizde, Frontend projenizin içindeki Node.js sunucu kodu da tamamen Vercel/Cloudflare üzerinde barınmış olur. Vercel sizin için bir sunucu kiralar veya "Serverless Function" (sunucusuz fonksiyon) altyapısında bu Node.js kodunu çalıştırır.

#### SSR Çalıştırma Yöntemleri (Adapter Mantığı)

Bir modern framework'ü SSR (Server-Side Rendering) veya ISR modunda çalıştırdığınızda, sayfayı her istekte veya ISR sürelerinde arka planda üretecek bir JavaScript çalışma zamanına (Node.js, Deno veya Cloudflare Workers) ihtiyaç duyulur.

Framework'ler size adapte edilebilir bir yapı (adapters) sunar:

* **Vercel Adapter Kullanırsanız:** Çıktılarınızı Vercel Serverless Functions olarak derler.
* **Cloudflare Adapter Kullanırsanız:** Çıktılarınızı Cloudflare Edge Workers üzerinde çalışan sıfır-gecikmeli sunucusuz koda çevirir.
* **Node.js Adapter Kullanırsanız:** Kendi AWS EC2 veya Docker container'ınızda çalıştırabileceğiniz standart bir Node.js sunucusu (`node dist/server/entry.mjs`) üretir.