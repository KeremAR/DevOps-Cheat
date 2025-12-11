# Sudoers Yönetimi: Adım Adım Kısıtlama Testi

Bu senaryoda amacımız farkı net bir şekilde görmektir. Önce kullanıcıya "Her şeyi yapabilir" (Sudo Grubu) yetkisi vereceğiz, çalıştığını göreceğiz. Sonra yetkiyi alıp, sadece "Bizim istediklerimizi yapabilir" (Whitelist/Alias) yöntemine geçeceğiz.

## Aşama 1: "Sudo" Grubu ile Tam Yetki (Baseline Testi)

Önce kullanıcının sistemin efendisi olduğu (root ile eşdeğer) durumu görelim.

1. **Test Kullanıcısı Oluştur ve Gruba Ekle:**
   *(Ana kullanıcınla yap)*
   ```bash
   sudo adduser junior_staff
   sudo usermod -aG sudo junior_staff
   ```

2. **Tam Yetki Testi:**
   `junior_staff` kullanıcısına geç ve root yetkisi gerektiren herhangi bir komut dene.
   ```bash
   su - junior_staff
   
   # Sudo grubunda olduğu için bu çalışacaktır:
   sudo apt update
   # Veya
   sudo fdisk -l
   ```
   *Sonuç: Komutlar çalışır. Kullanıcı her şeyi yapabilir.*

---

## Aşama 2: Sudo Grubundan Çıkarma (Yetkisizleştirme)

Şimdi kısıtlı yetki tanımlamadan önce, kullanıcının "Global" yetkisini elinden almamız lazım.

1. **Grubu Temizle (ID Kullanarak):**
   *(Ana kullanıcınla yap)*
   
   Kullanıcı adını bilmesek bile ID'si (örneğin 1000) üzerinden işlem yapabiliriz.
   **Dikkat:** UID 1000 genelde sistemi kuran ilk kullanıcıdır (senin durumunda `ubuntuprox`). Kendini kısıtlamadığından emin ol veya bunu sadece test kullanıcısının ID'si (örn. 1001) için yap.
   
   ```bash
   # ID'si 1001 olan kullanıcıyı bul ve sudo grubundan at:
   # (junior_staff muhtemelen 1001 olacaktır, id junior_staff ile bakabilirsin)
   sudo deluser $(getent passwd 1001 | cut -d: -f1) sudo
   
   # Eğer kesinlikle 1000 ID'sini kullanmak istiyorsan:
   # sudo deluser $(getent passwd 1000 | cut -d: -f1) sudo
   ```

2. **Yetkisizlik Testi:**
   Tekrar `junior_staff` ile dene.
   ```bash
   su - junior_staff
   sudo apt update
   ```
   *Sonuç: Hata verir. "user junior_staff is not in the sudoers file." der. Şu an hiçbir sudo yetkisi yok.*

---

## Aşama 3: Alias ve Whitelist ile Kısıtlı Yetki

Şimdi "Alias" kullanarak sadece belirli okuma (read-only) komutlarına izin verelim.

1. **Kural Dosyasını Oluştur:**
   *(Ana kullanıcınla)*
   ```bash
   sudo visudo -f /etc/sudoers.d/staff_rules
   ```

2. **İçeriği Yaz (Alias Kullanarak):**
   Burada 2 farklı Alias grubu tanımlayacağız: `IZLEME` (Log/Disk bakma) ve `SERVIS` (Ssh durumu bakma).

   ```sudoers
   # --- ALIAS TANIMLARI ---
   # Host Alias (Gerekirse hangi makinede geçerli olduğu) - Opsiyonel, genelde ALL kullanılır.
   
   # Command Alias (Komut Grupları)
   # Güvenlik notu: Komutların tam yolunu (/usr/bin/...) yazmak en iyisidir.
   # Yolu bulmak için 'which komut_adi' yazabilirsin.
   
   Cmnd_Alias IZLEME_ARACLARI = /usr/bin/df -h, /usr/bin/free -m, /usr/bin/cat /var/log/syslog
   Cmnd_Alias SERVIS_KONTROL = /usr/bin/systemctl status ssh
   
   # --- KURAL ---
   # junior_staff kullanıcısı, her hostta (ALL), root olarak (ALL),
   # sadece IZLEME_ARACLARI ve SERVIS_KONTROL gruplarındaki komutları çalıştırabilir.
   
   junior_staff ALL=(ALL) IZLEME_ARACLARI, SERVIS_KONTROL
   ```

3. **Dosyayı Kaydet ve Çık.** (`CTRL+X`, `Y`, `Enter`)

---

## Aşama 4: Final Test (Kısıtlı Yetki)

Şimdi `junior_staff` kullanıcısının durumuna tekrar bakalım.

1. **Kullanıcıya Geç:**
   ```bash
   su - junior_staff
   ```

2. **İzinli Komutları Dene (Çalışmalı):**
   ```bash
   sudo systemctl status ssh
   sudo df -h
   ```

3. **Yasaklı Komutları Dene (Çalışmamalı):**
   ```bash
   # Bu komut Alias listemizde yok:
   sudo apt update
   
   # Bu komut Alias'ta var (/usr/bin/cat) ama parametresi farklı/yasaklı dosya değilse?
   # Sudoers, komut satırını olduğu gibi eşleştirir.
   # Eğer kural '/usr/bin/cat /var/log/syslog' ise, kullanıcı 'sudo cat /etc/shadow' YAPAMAZ.
   sudo cat /etc/shadow
   ```
   *Sonuç: "Sorry, user junior_staff is not allowed to execute..." hatası almalısın.*


# Sudoers Yönetimi: ID veya Grup Tabanlı Kısıtlama

## Sorun: Her Kullanıcının İsmi Farklı, ID'si Aynı
Kullanıcı isimleri (`ahmet`, `mehmet`) değişse bile, şirketteki standart kurulumda o personelin **UID'si (Kullanıcı ID)** hep **1000** ise, sudoers dosyasında isim yerine ID kullanmak çok mantıklıdır.

Evet, sudoers dosyasında **UID (User ID)** kullanabilirsiniz.

---

## Yöntem 1: UID (Kullanıcı ID) Kullanmak (En Kolayı)

Sudoers dosyasında kullanıcı adı yerine `#` işaretiyle ID yazabilirsiniz.
Eğer her personelin makinesinde ana kullanıcı ID'si **1000** ise, aşağıdaki kural o ID'ye sahip olan **her kimse** onun için geçerli olur.

**Kural Dosyası (`/etc/sudoers.d/staff_rules`):**

```sudoers
# --- ALIAS TANIMLARI ---
Cmnd_Alias IZLEME_ARACLARI = \
    /usr/bin/df -h, \
    /usr/bin/free -m, \
    /usr/bin/cat /var/log/syslog, \
    /usr/bin/apt update
    
Cmnd_Alias SERVIS_KONTROL = /usr/bin/systemctl status ssh

# --- YETKİLENDİRME (UID KULLANARAK) ---
# Kullanıcı adı yerine #1000 yazıyoruz.
# #1000 (yani UID'si 1000 olan kişi), şifresini girerek bu komutları çalıştırabilir.

#1000 ALL=(ALL) IZLEME_ARACLARI, SERVIS_KONTROL
```

*Not: Eğer test kullanıcın `junior_staff` ise ve ID'si 1001 ise, test ederken `#1001` yazman gerekir. Canlı sistemlerde (staff bilgisayarlarında) `#1000` yazarsın.*

---

## Yöntem 2: Özel Bir Grup Kullanmak (Daha Yönetilebilir)

Eğer ID'ler ileride karışırsa veya birden fazla kişiye aynı yetkiyi vermek isterseniz, **Grup** tabanlı yönetim en profesyonel yöntemdir.

1.  **Sistemde özel bir grup oluştur:**
    ```bash
    sudo groupadd limited_staff
    ```

2.  **Kullanıcıyı bu gruba ekle:**
    *(Kullanıcı adı ne olursa olsun, bu gruba eklenen kısıtlanır)*
    ```bash
    sudo usermod -aG limited_staff junior_staff
    ```

3.  **Sudoers dosyasına GRUP kuralı yaz:**
    *(Gruplar `%` işaretiyle belirtilir)*

    ```sudoers
    # --- YETKİLENDİRME (GRUP KULLANARAK) ---
    # limited_staff grubundaki herkes bu kurallara uyar.
    
    %limited_staff ALL=(ALL) IZLEME_ARACLARI, SERVIS_KONTROL
    ```

---

## Hangisini Seçmelisin?
*   **Senin Durumun (Tek Kullanıcılı Staff PC'leri):** Her PC'de tek bir ana kullanıcı var ve ID'si hep 1000 ise, **Yöntem 1 (#1000)** en pratiğidir. Tek bir dosyayı (Ansible vb. ile) tüm PC'lere kopyalarsın ve çalışır. Kullanıcı adının ne olduğu önemsizleşir.

## Test Adımı (ID ile)
Hadi bunu test edelim.

1.  `junior_staff` kullanıcısının ID'sini öğren: `id -u junior_staff` (Muhtemelen 1001)
2.  `sudo visudo -f /etc/sudoers.d/staff_rules` dosyasını aç.
3.  Satırı şöyle değiştir:
    `#1001 ALL=(ALL) IZLEME_ARACLARI, SERVIS_KONTROL`
4.  Test et. Çalışırsa, production dosyasında `#1000` yapıp dağıtabilirsin.

---

## 4. Kritik Güvenlik Uyarısı: Root'a Geçişi (su - root) Engellemek

Kullanıcının `su -` veya `su - root` komutuyla root olması için **Root Şifresini bilmesi** gerekir.

1.  **Sudo Şifresi vs. Root Şifresi:**
    *   Kullanıcı `sudo` komutu çalıştırırken **kendi şifresini** girer.
    *   Kullanıcı `su -` komutu çalıştırırken **hedef kullanıcının (root) şifresini** girmek zorundadır.

**Çözüm:** Root şifresini kullanıcıya vermediğin sürece `su -` yapamazlar.
Ancak daha önemli bir risk vardır: **Shell Escape**.

### Shell Escape Nedir?
Bazı programlar (vi, less, more, man) kendi içinden komut çalıştırmaya izin verir.
Örnek: Eğer bir kullanıcıya `sudo vi /etc/hosts` yetkisi verirseniz, vi içinden `:!/bin/bash` yazarak root shell'e düşebilir. **Şifre sormadan root olur.**

**Bunu Engellemek İçin: NOEXEC**
Sudo kurallarında editör veya shell açabilecek programlara izin veriyorsanız `NOEXEC:` etiketini kullanmalısınız.

```sudoers
# Örnek: NOEXEC kullanımı
# Kullanıcı bu komutları çalıştırabilir ama komutun içinden başka bir shell başlatamaz.
Cmnd_Alias RISKLI_ARACLAR = /usr/bin/vim, /usr/bin/less

#1000 ALL=(ALL) NOEXEC: RISKLI_ARACLAR
```

**En Güvenli Yöntem:**
Kullanıcılara asla editör (`vim`, `nano`) yetkisini doğrudan sudo ile vermeyin. Dosya düzenlemeleri gerekiyorsa `sudoedit` kullanmalarını sağlayın veya sadece gerekli scriptleri çalıştırmalarına izin verin.

# Sudoers: Alias Tanımlarında Wildcard (Yıldız) Kullanımı

Sudoers dosyasında komutları tanımlarken iki seçeneğin var. `apt` gibi komutlar için `*` (wildcard) kullanabilirsin ama güvenlik farklarını bilmek gerekir.

## Yol 1: Tek Tek Tanımlama (Güvenli Yöntem)
En güvenli yöntem, sadece izin vermek istediğin alt komutları açıkça yazmaktır.
Ancak dikkat: `update` tek başına çalışır ama `install` ve `remove` yanına paket ismi ister. Bu yüzden onlara `*` eklemen gerekir.

```sudoers
# update ve upgrade yanına parametre almaz (genelde)
# install ve remove ise yanına paket ismi alacağı için sonlarına * koyarız.

Cmnd_Alias YAZILIM_YONETIMI = \
    /usr/bin/apt update, \
    /usr/bin/apt upgrade, \
    /usr/bin/apt install *, \
    /usr/bin/apt remove *
```
*Bu yöntem sayesinde kullanıcı `apt purge` veya `apt autoremove` yapamaz. Sadece senin izin verdiklerini yapar.*

## Yol 2: Wildcard Kullanımı (Gevşek Yöntem)
Eğer "apt ile başlayan her şeyi yapabilsin (update, install, search, purge vs.)" dersen, komutun sonuna tek bir `*` koyman yeterlidir.

```sudoers
# /usr/bin/apt komutundan sonra ne gelirse gelsin kabul et:

Cmnd_Alias YAZILIM_YONETIMI = /usr/bin/apt *
```
*Bu yöntem çok daha kısadır ama kullanıcı `sudo apt purge mysql-server` gibi tehlikeli (senin listende olmayan) komutları da çalıştırabilir.*

## Örnek: Systemctl ile Servis Yönetimi (Wildcard Kullanımı)

Eğer kullanıcıya birden fazla servisi yönetme yetkisi vermek istiyorsan (docker, kafka, redis vb.) ve bu servislere sadece belirli komutları (start, stop, restart vb.) uygulayabilsin istiyorsan, iki yol var:

### Yol 1: Her Servis İçin Ayrı Satır (Uzun Ama Açık)
Her servis ve her komut kombinasyonunu tek tek yazarsın:

```sudoers
Cmnd_Alias SERVIS_YONETIMI = \
    /usr/bin/systemctl start docker*, \
    /usr/bin/systemctl stop docker*, \
    /usr/bin/systemctl restart docker*, \
    /usr/bin/systemctl enable docker*, \
    /usr/bin/systemctl disable docker*, \
    /usr/bin/systemctl start kafka*, \
    /usr/bin/systemctl stop kafka*, \
    /usr/bin/systemctl restart kafka*, \
    /usr/bin/systemctl enable kafka*, \
    /usr/bin/systemctl disable kafka*, \
    /usr/bin/systemctl start redis*, \
    /usr/bin/systemctl stop redis*, \
    /usr/bin/systemctl restart redis*, \
    /usr/bin/systemctl enable redis*, \
    /usr/bin/systemctl disable redis*, \
    /usr/bin/systemctl start mysql*, \
    /usr/bin/systemctl stop mysql*, \
    /usr/bin/systemctl restart mysql*, \
    /usr/bin/systemctl enable mysql*, \
    /usr/bin/systemctl disable mysql*, \
    /usr/bin/systemctl start postgresql*, \
    /usr/bin/systemctl stop postgresql*, \
    /usr/bin/systemctl restart postgresql*, \
    /usr/bin/systemctl enable postgresql*, \
    /usr/bin/systemctl disable postgresql*, \
    /usr/bin/systemctl start zookeeper*, \
    /usr/bin/systemctl stop zookeeper*, \
    /usr/bin/systemctl restart zookeeper*, \
    /usr/bin/systemctl enable zookeeper*, \
    /usr/bin/systemctl disable zookeeper*, \
    /usr/bin/systemctl start elasticsearch*, \
    /usr/bin/systemctl stop elasticsearch*, \
    /usr/bin/systemctl restart elasticsearch*, \
    /usr/bin/systemctl enable elasticsearch*, \
    /usr/bin/systemctl disable elasticsearch*, \
    /usr/bin/systemctl start nginx*, \
    /usr/bin/systemctl stop nginx*, \
    /usr/bin/systemctl restart nginx*, \
    /usr/bin/systemctl enable nginx*, \
    /usr/bin/systemctl disable nginx*
```

### Yol 2: Tek Wildcard ile Kısayol (En Pratik Ama Dikkatli Kullan)
Eğer "systemctl'in belirli komutlarını her servise uygulayabilsin" dersen:

```sudoers
# Sadece belirli systemctl komutlarına izin ver, servis ismi ne olursa olsun:
Cmnd_Alias SERVIS_YONETIMI = \
    /usr/bin/systemctl start *, \
    /usr/bin/systemctl stop *, \
    /usr/bin/systemctl restart *, \
    /usr/bin/systemctl enable *, \
    /usr/bin/systemctl disable *
```
*Bu yöntemle kullanıcı `sudo systemctl start apache2` veya `sudo systemctl stop sshd` gibi komutları da çalıştırabilir. Sadece listedeki servislere izin vermek istiyorsan Yol 1'i kullan.*

### Yol 3: En Gevşek - Tüm Systemctl İşlemleri
Eğer "systemctl ile ilgili her şeyi yapabilsin" dersen (ÇOK RİSKLİ):

```sudoers
Cmnd_Alias SERVIS_YONETIMI = /usr/bin/systemctl *
```
⚠️ **Uyarı:** Bu yöntem kullanıcıya `sudo systemctl daemon-reload`, `sudo systemctl mask`, `sudo systemctl poweroff` gibi kritik komutları da çalıştırma yetkisi verir. Önerilmez!
