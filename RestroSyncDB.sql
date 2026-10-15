-- =====================================================================
-- RestroSync — Masa ve Sipariş Yönetim Sistemi
-- Veritabanı Kurulum ve Örnek Veri Scripti (DB-01)
-- Hedef Motor: MySQL / MariaDB (InnoDB, utf8mb4)
-- =====================================================================

CREATE DATABASE IF NOT EXISTS `RestroSyncDB` 
CHARACTER SET utf8mb4 
COLLATE utf8mb4_turkish_ci;

USE `RestroSyncDB`;

-- Varsa eski tabloları ters sıra ile kaldır
SET FOREIGN_KEY_CHECKS = 0;
DROP TABLE IF EXISTS `SiparisDetay`;
DROP TABLE IF EXISTS `Siparis`;
DROP TABLE IF EXISTS `Urun`;
DROP TABLE IF EXISTS `Kategori`;
DROP TABLE IF EXISTS `Masa`;
SET FOREIGN_KEY_CHECKS = 1;

-- 1. MASA TABLOSU
-- Masaların krokideki fiziksel temsili ve doluluk durumları
CREATE TABLE `Masa` (
    `MasaID` INT AUTO_INCREMENT PRIMARY KEY,
    `MasaNo` VARCHAR(10) NOT NULL UNIQUE,
    `Kapasite` INT NOT NULL DEFAULT 4,
    `Durum` ENUM('Bos', 'Dolu', 'Bekliyor', 'Kirli') NOT NULL DEFAULT 'Bos'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_turkish_ci;

-- 2. KATEGORİ TABLOSU
-- Menü kalemlerinin sınıflandırılması
CREATE TABLE `Kategori` (
    `KategoriID` INT AUTO_INCREMENT PRIMARY KEY,
    `KategoriAdi` VARCHAR(50) NOT NULL UNIQUE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_turkish_ci;

-- 3. ÜRÜN TABLOSU
-- Restoran menüsündeki tüm yiyecek ve içecekler
CREATE TABLE `Urun` (
    `UrunID` INT AUTO_INCREMENT PRIMARY KEY,
    `KategoriID` INT NOT NULL,
    `UrunAdi` VARCHAR(100) NOT NULL,
    `Fiyat` DECIMAL(10,2) NOT NULL DEFAULT 0.00,
    CONSTRAINT `fk_urun_kategori` 
        FOREIGN KEY (`KategoriID`) 
        REFERENCES `Kategori` (`KategoriID`) 
        ON DELETE CASCADE 
        ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_turkish_ci;

-- 4. SİPARİŞ (ADİSYON) TABLOSU
-- Masalara ait adisyon başlık kayıtları
CREATE TABLE `Siparis` (
    `SiparisID` INT AUTO_INCREMENT PRIMARY KEY,
    `MasaID` INT NOT NULL,
    `SiparisZamani` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    `ToplamTutar` DECIMAL(10,2) NOT NULL DEFAULT 0.00,
    `Durum` ENUM('Beklemede', 'Hazirlaniyor', 'Hazir', 'Kapandi') NOT NULL DEFAULT 'Beklemede',
    `Garson` VARCHAR(50) NOT NULL DEFAULT 'Maria V.',
    `OdemeTuru` VARCHAR(20) NULL,
    CONSTRAINT `fk_siparis_masa` 
        FOREIGN KEY (`MasaID`) 
        REFERENCES `Masa` (`MasaID`) 
        ON DELETE RESTRICT 
        ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_turkish_ci;

-- 5. SİPARİŞ DETAY TABLOSU
-- Bir siparişteki kalemler, adetler ve anlık birim fiyatlar
CREATE TABLE `SiparisDetay` (
    `DetayID` INT AUTO_INCREMENT PRIMARY KEY,
    `SiparisID` INT NOT NULL,
    `UrunID` INT NOT NULL,
    `Adet` INT NOT NULL,
    `BirimFiyat` DECIMAL(10,2) NOT NULL,
    `EklenmeZamani` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT `fk_detay_siparis` 
        FOREIGN KEY (`SiparisID`) 
        REFERENCES `Siparis` (`SiparisID`) 
        ON DELETE CASCADE 
        ON UPDATE CASCADE,
    CONSTRAINT `fk_detay_urun` 
        FOREIGN KEY (`UrunID`) 
        REFERENCES `Urun` (`UrunID`) 
        ON DELETE RESTRICT 
        ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_turkish_ci;

-- =====================================================================
-- BAŞLANGIÇ VE TEST VERİLERİ (SEED DATA)
-- =====================================================================

-- 18 Adet Masa Tanımı (T01 - T18)
INSERT INTO `Masa` (`MasaID`, `MasaNo`, `Kapasite`, `Durum`) VALUES
(1, 'T01', 4, 'Dolu'),
(2, 'T02', 2, 'Bos'),
(3, 'T03', 4, 'Bekliyor'),
(4, 'T04', 4, 'Dolu'),
(5, 'T05', 2, 'Bos'),
(6, 'T06', 6, 'Bos'),
(7, 'T07', 4, 'Bos'),
(8, 'T08', 8, 'Dolu'),
(9, 'T09', 2, 'Bos'),
(10, 'T10', 4, 'Kirli'),
(11, 'T11', 4, 'Bos'),
(12, 'T12', 6, 'Dolu'),
(13, 'T13', 2, 'Bos'),
(14, 'T14', 4, 'Bos'),
(15, 'T15', 6, 'Bos'),
(16, 'T16', 4, 'Bos'),
(17, 'T17', 2, 'Bos'),
(18, 'T18', 8, 'Bos');

-- Menü Kategorileri
INSERT INTO `Kategori` (`KategoriID`, `KategoriAdi`) VALUES
(1, 'Ana Yemekler'),
(2, 'Başlangıçlar & Yanlar'),
(3, 'Salatalar'),
(4, 'Tatlılar'),
(5, 'İçecekler');

-- Menü Ürünleri
INSERT INTO `Urun` (`UrunID`, `KategoriID`, `UrunAdi`, `Fiyat`) VALUES
-- Ana Yemekler
(1, 1, 'Ribeye Steak', 480.00),
(2, 1, 'Chicken Pasta', 260.00),
(3, 1, 'Pizza Margherita', 280.00),
(4, 1, 'Izgara Köfte', 290.00),
(5, 1, 'Tavuk Şnitzel', 250.00),
(6, 1, 'Somon Izgara', 420.00),
-- Başlangıçlar
(7, 2, 'Fries (Patates Kızartması)', 95.00),
(8, 2, 'Patates Püresi', 85.00),
(9, 2, 'Günün Çorbası', 75.00),
(10, 2, 'Çıtır Tavuk Sepeti', 160.00),
-- Salatalar
(11, 3, 'Akdeniz Salata', 120.00),
(12, 3, 'Sezar Salata', 155.00),
(13, 3, 'Roka & Tulum Peynirli', 135.00),
-- Tatlılar
(14, 4, 'Sıcak Çikolatalı Sufle', 140.00),
(15, 4, 'San Sebastian Cheesecake', 150.00),
(16, 4, 'Tiramisu', 130.00),
-- İçecekler
(17, 5, 'Kutu Kola / Soda', 55.00),
(18, 5, 'Kırmızı Şarap (Kadeh)', 240.00),
(19, 5, 'Kırmızı Şarap (Şişe)', 680.00),
(20, 5, 'Ev Yapımı Limonata', 65.00),
(21, 5, 'Taze Sıkma Portakal Suyu', 75.00),
(22, 5, 'Su (750ml Cam)', 35.00),
(23, 5, 'Espresso / Kahve', 60.00);

-- Örnek Aktif Siparişler
-- Sipariş #1104 (Masa T12 - Durum: Hazır)
INSERT INTO `Siparis` (`SiparisID`, `MasaID`, `SiparisZamani`, `ToplamTutar`, `Durum`, `Garson`) 
VALUES (1104, 12, DATE_SUB(NOW(), INTERVAL 35 MINUTE), 335.00, 'Hazir', 'Ahmet K.');

INSERT INTO `SiparisDetay` (`SiparisID`, `UrunID`, `Adet`, `BirimFiyat`) VALUES
(1104, 3, 1, 280.00), -- Pizza Margherita
(1104, 17, 1, 55.00);  -- Kutu Kola

-- Sipariş #1105 (Masa T01 - Durum: Hazirlaniyor)
INSERT INTO `Siparis` (`SiparisID`, `MasaID`, `SiparisZamani`, `ToplamTutar`, `Durum`, `Garson`) 
VALUES (1105, 1, DATE_SUB(NOW(), INTERVAL 20 MINUTE), 780.00, 'Hazirlaniyor', 'Maria V.');

INSERT INTO `SiparisDetay` (`SiparisID`, `UrunID`, `Adet`, `BirimFiyat`) VALUES
(1105, 1, 1, 480.00),  -- Ribeye Steak
(1105, 7, 1, 95.00),   -- Fries
(1105, 8, 1, 85.00),   -- Püre
(1105, 11, 1, 120.00); -- Salata

-- Sipariş #1106 (Masa T08 - Durum: Beklemede)
INSERT INTO `Siparis` (`SiparisID`, `MasaID`, `SiparisZamani`, `ToplamTutar`, `Durum`, `Garson`) 
VALUES (1106, 8, DATE_SUB(NOW(), INTERVAL 10 MINUTE), 500.00, 'Beklemede', 'Can B.');

INSERT INTO `SiparisDetay` (`SiparisID`, `UrunID`, `Adet`, `BirimFiyat`) VALUES
(1106, 2, 1, 260.00),  -- Chicken Pasta
(1106, 18, 1, 240.00); -- Kırmızı Şarap

-- Örnek Geçmiş Kapanmış Sipariş (Bugünkü Ciro için)
INSERT INTO `Siparis` (`SiparisID`, `MasaID`, `SiparisZamani`, `ToplamTutar`, `Durum`, `Garson`, `OdemeTuru`) 
VALUES (1100, 2, DATE_SUB(NOW(), INTERVAL 2 HOUR), 540.00, 'Kapandi', 'Maria V.', 'Kredi Kartı');

INSERT INTO `SiparisDetay` (`SiparisID`, `UrunID`, `Adet`, `BirimFiyat`) VALUES
(1100, 4, 1, 290.00),
(1100, 15, 1, 150.00),
(1100, 20, 1, 65.00),
(1100, 22, 1, 35.00);

INSERT INTO `Siparis` (`SiparisID`, `MasaID`, `SiparisZamani`, `ToplamTutar`, `Durum`, `Garson`, `OdemeTuru`) 
VALUES (1101, 7, DATE_SUB(NOW(), INTERVAL 3 HOUR), 620.00, 'Kapandi', 'Ahmet K.', 'Nakit');

INSERT INTO `SiparisDetay` (`SiparisID`, `UrunID`, `Adet`, `BirimFiyat`) VALUES
(1101, 5, 2, 250.00),
(1101, 11, 1, 120.00);

-- =====================================================================
-- KULLANIŞLI VIEW VE PROSEDÜRLER
-- =====================================================================

CREATE OR REPLACE VIEW `vw_MutfakKuyrugu` AS
SELECT 
    s.SiparisID,
    m.MasaNo,
    s.Garson,
    s.SiparisZamani,
    s.Durum,
    GROUP_CONCAT(CONCAT(sd.Adet, 'x ', u.UrunAdi) SEPARATOR ', ') AS UrunlerOzet,
    s.ToplamTutar
FROM Siparis s
JOIN Masa m ON s.MasaID = m.MasaID
JOIN SiparisDetay sd ON s.SiparisID = sd.SiparisID
JOIN Urun u ON sd.UrunID = u.UrunID
WHERE s.Durum IN ('Beklemede', 'Hazirlaniyor', 'Hazir')
GROUP BY s.SiparisID, m.MasaNo, s.Garson, s.SiparisZamani, s.Durum, s.ToplamTutar
ORDER BY 
    CASE s.Durum 
        WHEN 'Beklemede' THEN 1 
        WHEN 'Hazirlaniyor' THEN 2 
        WHEN 'Hazir' THEN 3 
        ELSE 4 
    END,
    s.SiparisZamani ASC;
