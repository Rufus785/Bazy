USE [master]
GO
/****** Object:  Database [projekt]    Script Date: 24.05.2024 19:38:03 ******/
CREATE DATABASE [projekt]
 CONTAINMENT = NONE
 ON  PRIMARY 
( NAME = N'projekt', FILENAME = N'C:\Program Files\Microsoft SQL Server\MSSQL16.MSSQLSERVER\MSSQL\DATA\projekt.mdf' , SIZE = 73728KB , MAXSIZE = UNLIMITED, FILEGROWTH = 65536KB )
 LOG ON 
( NAME = N'projekt_log', FILENAME = N'C:\Program Files\Microsoft SQL Server\MSSQL16.MSSQLSERVER\MSSQL\DATA\projekt_log.ldf' , SIZE = 139264KB , MAXSIZE = 2048GB , FILEGROWTH = 65536KB )
 WITH CATALOG_COLLATION = DATABASE_DEFAULT, LEDGER = OFF
GO
ALTER DATABASE [projekt] SET COMPATIBILITY_LEVEL = 160
GO
IF (1 = FULLTEXTSERVICEPROPERTY('IsFullTextInstalled'))
begin
EXEC [projekt].[dbo].[sp_fulltext_database] @action = 'enable'
end
GO
ALTER DATABASE [projekt] SET ANSI_NULL_DEFAULT OFF 
GO
ALTER DATABASE [projekt] SET ANSI_NULLS OFF 
GO
ALTER DATABASE [projekt] SET ANSI_PADDING OFF 
GO
ALTER DATABASE [projekt] SET ANSI_WARNINGS OFF 
GO
ALTER DATABASE [projekt] SET ARITHABORT OFF 
GO
ALTER DATABASE [projekt] SET AUTO_CLOSE OFF 
GO
ALTER DATABASE [projekt] SET AUTO_SHRINK OFF 
GO
ALTER DATABASE [projekt] SET AUTO_UPDATE_STATISTICS ON 
GO
ALTER DATABASE [projekt] SET CURSOR_CLOSE_ON_COMMIT OFF 
GO
ALTER DATABASE [projekt] SET CURSOR_DEFAULT  GLOBAL 
GO
ALTER DATABASE [projekt] SET CONCAT_NULL_YIELDS_NULL OFF 
GO
ALTER DATABASE [projekt] SET NUMERIC_ROUNDABORT OFF 
GO
ALTER DATABASE [projekt] SET QUOTED_IDENTIFIER OFF 
GO
ALTER DATABASE [projekt] SET RECURSIVE_TRIGGERS OFF 
GO
ALTER DATABASE [projekt] SET  DISABLE_BROKER 
GO
ALTER DATABASE [projekt] SET AUTO_UPDATE_STATISTICS_ASYNC OFF 
GO
ALTER DATABASE [projekt] SET DATE_CORRELATION_OPTIMIZATION OFF 
GO
ALTER DATABASE [projekt] SET TRUSTWORTHY OFF 
GO
ALTER DATABASE [projekt] SET ALLOW_SNAPSHOT_ISOLATION OFF 
GO
ALTER DATABASE [projekt] SET PARAMETERIZATION SIMPLE 
GO
ALTER DATABASE [projekt] SET READ_COMMITTED_SNAPSHOT OFF 
GO
ALTER DATABASE [projekt] SET HONOR_BROKER_PRIORITY OFF 
GO
ALTER DATABASE [projekt] SET RECOVERY FULL 
GO
ALTER DATABASE [projekt] SET  MULTI_USER 
GO
ALTER DATABASE [projekt] SET PAGE_VERIFY CHECKSUM  
GO
ALTER DATABASE [projekt] SET DB_CHAINING OFF 
GO
ALTER DATABASE [projekt] SET FILESTREAM( NON_TRANSACTED_ACCESS = OFF ) 
GO
ALTER DATABASE [projekt] SET TARGET_RECOVERY_TIME = 60 SECONDS 
GO
ALTER DATABASE [projekt] SET DELAYED_DURABILITY = DISABLED 
GO
ALTER DATABASE [projekt] SET ACCELERATED_DATABASE_RECOVERY = OFF  
GO
EXEC sys.sp_db_vardecimal_storage_format N'projekt', N'ON'
GO
ALTER DATABASE [projekt] SET QUERY_STORE = ON
GO
ALTER DATABASE [projekt] SET QUERY_STORE (OPERATION_MODE = READ_WRITE, CLEANUP_POLICY = (STALE_QUERY_THRESHOLD_DAYS = 30), DATA_FLUSH_INTERVAL_SECONDS = 900, INTERVAL_LENGTH_MINUTES = 60, MAX_STORAGE_SIZE_MB = 1000, QUERY_CAPTURE_MODE = AUTO, SIZE_BASED_CLEANUP_MODE = AUTO, MAX_PLANS_PER_QUERY = 200, WAIT_STATS_CAPTURE_MODE = ON)
GO
USE [projekt]
GO
/****** Object:  User [readwrite_user]    Script Date: 24.05.2024 19:38:03 ******/
CREATE USER [readwrite_user] FOR LOGIN [readwrite_user] WITH DEFAULT_SCHEMA=[dbo]
GO
/****** Object:  User [readonly_user]    Script Date: 24.05.2024 19:38:03 ******/
CREATE USER [readonly_user] FOR LOGIN [readonly_user] WITH DEFAULT_SCHEMA=[dbo]
GO
ALTER ROLE [db_ddladmin] ADD MEMBER [readwrite_user]
GO
ALTER ROLE [db_datawriter] ADD MEMBER [readwrite_user]
GO
ALTER ROLE [db_datareader] ADD MEMBER [readonly_user]
GO
/****** Object:  UserDefinedFunction [dbo].[SredniaCenaZamowienia]    Script Date: 24.05.2024 19:38:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[SredniaCenaZamowienia] (@id_zamowienia INT)
RETURNS DECIMAL(10, 2)
AS
BEGIN
    DECLARE @srednia DECIMAL(10, 2)

    SELECT @srednia = AVG(z.ilosc * t.aktualna_cena)
    FROM zamowienia_tow z
    INNER JOIN towary t ON z.towary_id_towary = t.id_towary
    WHERE z.zamowienia_id_zamowienia = @id_zamowienia

    RETURN @srednia
END
GO
/****** Object:  UserDefinedFunction [dbo].[SumaCenWKategorii]    Script Date: 24.05.2024 19:38:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[SumaCenWKategorii] (@id_kategorii INT)
RETURNS @wynik TABLE
(
    suma_cen DECIMAL(10, 2)
)
AS
BEGIN
    DECLARE @suma DECIMAL(10, 2)

    SELECT @suma = SUM(aktualna_cena)
    FROM towary
    WHERE kategorie_id_kategorie = @id_kategorii

    INSERT INTO @wynik (suma_cen) VALUES (@suma)

    RETURN
END
GO
/****** Object:  Table [dbo].[towary]    Script Date: 24.05.2024 19:38:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[towary](
	[id_towary] [int] NOT NULL,
	[nazwa] [varchar](255) NOT NULL,
	[aktualna_cena] [decimal](10, 2) NOT NULL,
	[kategorie_id_kategorie] [int] NOT NULL,
 CONSTRAINT [towary_pk] PRIMARY KEY CLUSTERED 
(
	[id_towary] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  UserDefinedFunction [dbo].[TowaryWKategorii]    Script Date: 24.05.2024 19:38:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[TowaryWKategorii] (@id_kategorii INT)
RETURNS TABLE
AS
RETURN (
    SELECT id_towary, nazwa, aktualna_cena
    FROM towary
    WHERE kategorie_id_kategorie = @id_kategorii
)
GO
/****** Object:  View [dbo].[WidokTowarow]    Script Date: 24.05.2024 19:38:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[WidokTowarow]
AS
SELECT id_towary, nazwa, aktualna_cena
FROM towary
WHERE aktualna_cena > 20.00;
 
GO
/****** Object:  Table [dbo].[transakcje]    Script Date: 24.05.2024 19:38:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[transakcje](
	[id_transakcje] [int] NOT NULL,
	[typ_transakcji] [char](1) NOT NULL,
	[kwota] [decimal](10, 2) NOT NULL,
	[nr_konta] [int] NOT NULL,
 CONSTRAINT [transakcje_pk] PRIMARY KEY CLUSTERED 
(
	[id_transakcje] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  View [dbo].[IndeksowanyWidokTransakcji]    Script Date: 24.05.2024 19:38:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[IndeksowanyWidokTransakcji]
WITH SCHEMABINDING
AS
SELECT id_transakcje, typ_transakcji, kwota, nr_konta
FROM dbo.transakcje;
GO
SET ARITHABORT ON
SET CONCAT_NULL_YIELDS_NULL ON
SET QUOTED_IDENTIFIER ON
SET ANSI_NULLS ON
SET ANSI_PADDING ON
SET ANSI_WARNINGS ON
SET NUMERIC_ROUNDABORT OFF
GO
/****** Object:  Index [IDX_IndeksowanyWidokTransakcji]    Script Date: 24.05.2024 19:38:03 ******/
CREATE UNIQUE CLUSTERED INDEX [IDX_IndeksowanyWidokTransakcji] ON [dbo].[IndeksowanyWidokTransakcji]
(
	[id_transakcje] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[ddl_log]    Script Date: 24.05.2024 19:38:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ddl_log](
	[event_time] [datetime] NOT NULL,
	[event_type] [nvarchar](100) NULL,
	[object_name] [nvarchar](255) NULL,
	[object_type] [nvarchar](255) NULL,
	[sql_command] [nvarchar](max) NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[kategorie]    Script Date: 24.05.2024 19:38:04 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[kategorie](
	[id_kategorie] [int] NOT NULL,
	[nazwa] [varchar](255) NOT NULL,
	[opis] [varchar](255) NULL,
 CONSTRAINT [kategorie_pk] PRIMARY KEY CLUSTERED 
(
	[id_kategorie] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[TempZamowioneTowary]    Script Date: 24.05.2024 19:38:04 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[TempZamowioneTowary](
	[id_towary] [int] NULL,
	[ilosc_zamowiona] [int] NULL
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[uzytkownicy]    Script Date: 24.05.2024 19:38:04 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[uzytkownicy](
	[id_uzytkownicy] [int] NOT NULL,
	[login] [varchar](255) NOT NULL,
	[haslo] [varchar](255) NOT NULL,
 CONSTRAINT [uzytkownicy_pk] PRIMARY KEY CLUSTERED 
(
	[id_uzytkownicy] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[zamowienia]    Script Date: 24.05.2024 19:38:04 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[zamowienia](
	[id_zamowienia] [int] NOT NULL,
	[data] [date] NOT NULL,
	[imie_nazwisko] [varchar](255) NULL,
	[ulica_dostawy] [varchar](255) NOT NULL,
	[nr_domu_dostawy] [varchar](255) NOT NULL,
	[kod_pocztowy_dostawy] [varchar](255) NOT NULL,
	[miasto_dostawy] [varchar](255) NOT NULL,
	[info_kurier] [varchar](255) NULL,
	[faktura] [char](1) NOT NULL,
	[status] [varchar](255) NOT NULL,
	[uzytkownicy_id_uzytkownicy] [int] NOT NULL,
	[transakcje_id_transakcje] [int] NOT NULL,
 CONSTRAINT [zamowienia_pk] PRIMARY KEY CLUSTERED 
(
	[id_zamowienia] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[zamowienia_tow]    Script Date: 24.05.2024 19:38:04 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[zamowienia_tow](
	[id_zam_tow] [int] NOT NULL,
	[ilosc] [int] NOT NULL,
	[cena_szt] [decimal](10, 2) NOT NULL,
	[zamowienia_id_zamowienia] [int] NOT NULL,
	[towary_id_towary] [int] NOT NULL,
	[kwota]  AS ([ilosc]*[cena_szt]),
 CONSTRAINT [zamowienia_tow_pk] PRIMARY KEY CLUSTERED 
(
	[id_zam_tow] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[zwroty]    Script Date: 24.05.2024 19:38:04 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[zwroty](
	[id_zwroty] [int] NOT NULL,
	[data] [date] NOT NULL,
	[powod] [varchar](255) NULL,
	[status] [varchar](255) NOT NULL,
	[ilosc] [int] NOT NULL,
	[uzytkownicy_id_uzytkownicy] [int] NOT NULL,
	[zamowienia_tow_id_zam_tow] [int] NOT NULL,
	[transakcje_id_transakcje] [int] NOT NULL,
 CONSTRAINT [zwroty_pk] PRIMARY KEY CLUSTERED 
(
	[id_zwroty] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [idx_NonClustered_Kategorie]    Script Date: 24.05.2024 19:38:04 ******/
CREATE NONCLUSTERED INDEX [idx_NonClustered_Kategorie] ON [dbo].[kategorie]
(
	[nazwa] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [idx_towary_nazwa]    Script Date: 24.05.2024 19:38:04 ******/
CREATE NONCLUSTERED INDEX [idx_towary_nazwa] ON [dbo].[towary]
(
	[nazwa] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [idx_zamowienia_data]    Script Date: 24.05.2024 19:38:04 ******/
CREATE NONCLUSTERED INDEX [idx_zamowienia_data] ON [dbo].[zamowienia]
(
	[data] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [zamowienia__idx]    Script Date: 24.05.2024 19:38:04 ******/
CREATE UNIQUE NONCLUSTERED INDEX [zamowienia__idx] ON [dbo].[zamowienia]
(
	[transakcje_id_transakcje] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [idx_zwroty_data]    Script Date: 24.05.2024 19:38:04 ******/
CREATE NONCLUSTERED INDEX [idx_zwroty_data] ON [dbo].[zwroty]
(
	[data] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [zwroty__idx]    Script Date: 24.05.2024 19:38:04 ******/
CREATE UNIQUE NONCLUSTERED INDEX [zwroty__idx] ON [dbo].[zwroty]
(
	[transakcje_id_transakcje] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
ALTER TABLE [dbo].[ddl_log] ADD  DEFAULT (getdate()) FOR [event_time]
GO
ALTER TABLE [dbo].[zamowienia] ADD  DEFAULT ('0') FOR [faktura]
GO
ALTER TABLE [dbo].[towary]  WITH CHECK ADD  CONSTRAINT [towary_kategorie_fk] FOREIGN KEY([kategorie_id_kategorie])
REFERENCES [dbo].[kategorie] ([id_kategorie])
GO
ALTER TABLE [dbo].[towary] CHECK CONSTRAINT [towary_kategorie_fk]
GO
ALTER TABLE [dbo].[zamowienia]  WITH CHECK ADD  CONSTRAINT [zamowienia_transakcje_fk] FOREIGN KEY([transakcje_id_transakcje])
REFERENCES [dbo].[transakcje] ([id_transakcje])
GO
ALTER TABLE [dbo].[zamowienia] CHECK CONSTRAINT [zamowienia_transakcje_fk]
GO
ALTER TABLE [dbo].[zamowienia]  WITH CHECK ADD  CONSTRAINT [zamowienia_uzytkownicy_fk] FOREIGN KEY([uzytkownicy_id_uzytkownicy])
REFERENCES [dbo].[uzytkownicy] ([id_uzytkownicy])
GO
ALTER TABLE [dbo].[zamowienia] CHECK CONSTRAINT [zamowienia_uzytkownicy_fk]
GO
ALTER TABLE [dbo].[zamowienia_tow]  WITH CHECK ADD  CONSTRAINT [zamowienia_tow_towary_fk] FOREIGN KEY([towary_id_towary])
REFERENCES [dbo].[towary] ([id_towary])
GO
ALTER TABLE [dbo].[zamowienia_tow] CHECK CONSTRAINT [zamowienia_tow_towary_fk]
GO
ALTER TABLE [dbo].[zamowienia_tow]  WITH CHECK ADD  CONSTRAINT [zamowienia_tow_zamowienia_fk] FOREIGN KEY([zamowienia_id_zamowienia])
REFERENCES [dbo].[zamowienia] ([id_zamowienia])
GO
ALTER TABLE [dbo].[zamowienia_tow] CHECK CONSTRAINT [zamowienia_tow_zamowienia_fk]
GO
ALTER TABLE [dbo].[zwroty]  WITH CHECK ADD  CONSTRAINT [zwroty_transakcje_fk] FOREIGN KEY([transakcje_id_transakcje])
REFERENCES [dbo].[transakcje] ([id_transakcje])
GO
ALTER TABLE [dbo].[zwroty] CHECK CONSTRAINT [zwroty_transakcje_fk]
GO
ALTER TABLE [dbo].[zwroty]  WITH CHECK ADD  CONSTRAINT [zwroty_uzytkownicy_fk] FOREIGN KEY([uzytkownicy_id_uzytkownicy])
REFERENCES [dbo].[uzytkownicy] ([id_uzytkownicy])
GO
ALTER TABLE [dbo].[zwroty] CHECK CONSTRAINT [zwroty_uzytkownicy_fk]
GO
ALTER TABLE [dbo].[zwroty]  WITH CHECK ADD  CONSTRAINT [zwroty_zamowienia_tow_fk] FOREIGN KEY([zamowienia_tow_id_zam_tow])
REFERENCES [dbo].[zamowienia_tow] ([id_zam_tow])
GO
ALTER TABLE [dbo].[zwroty] CHECK CONSTRAINT [zwroty_zamowienia_tow_fk]
GO
/****** Object:  StoredProcedure [dbo].[DodajKategorie]    Script Date: 24.05.2024 19:38:04 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[DodajKategorie] @ilosc INT
AS
BEGIN
    DECLARE @i INT = 1
    WHILE @i <= @ilosc
    BEGIN
        BEGIN TRY
            INSERT INTO kategorie (id_kategorie, nazwa, opis)
            VALUES (@i, 'Kategoria ' + CAST(@i AS VARCHAR(10)), 'Opis kategorii ' + CAST(@i AS VARCHAR(10)))
        END TRY
        BEGIN CATCH
            -- Obsługa błędów
            PRINT 'Wystąpił błąd podczas dodawania kategorii ' + CAST(@i AS VARCHAR(10))
            -- Można również wywołać odpowiednią procedurę obsługi błędów lub zarejestrować informacje o błędzie gdzieś indziej
        END CATCH
        SET @i = @i + 1
    END
END
GO
/****** Object:  StoredProcedure [dbo].[DodajKategorieITowar]    Script Date: 24.05.2024 19:38:04 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[DodajKategorieITowar]
    @nazwaKategorii VARCHAR(255),
    @nazwaTowaru VARCHAR(255),
    @cena DECIMAL(10, 2),
    @opisKategorii VARCHAR(255),
    @opisTowaru VARCHAR(255)
AS
BEGIN
    BEGIN TRY
        BEGIN TRANSACTION;

        -- Dodanie nowej kategorii
        INSERT INTO kategorie (nazwa, opis)
        VALUES (@nazwaKategorii, @opisKategorii);

        -- Pobranie identyfikatora nowo dodanej kategorii
        DECLARE @idKategorii INT
        SET @idKategorii = SCOPE_IDENTITY();

        -- Dodanie nowego towaru należącego do tej kategorii
        INSERT INTO towary (nazwa, aktualna_cena, kategorie_id_kategorie)
        VALUES (@nazwaTowaru, @cena, @idKategorii);

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;

        -- Obsługa błędów
        PRINT 'Wystąpił błąd podczas dodawania kategorii i towaru.';
        PRINT ERROR_MESSAGE();
    END CATCH
END
GO
/****** Object:  StoredProcedure [dbo].[DodajKategorieOrazTowar]    Script Date: 24.05.2024 19:38:04 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[DodajKategorieOrazTowar]
    @nazwaKategorii VARCHAR(255),
    @nazwaTowaru VARCHAR(255),
    @cena DECIMAL(10, 2),
    @opisKategorii VARCHAR(255),
    @opisTowaru VARCHAR(255)
AS
BEGIN
    BEGIN TRY
        BEGIN TRANSACTION;


        DECLARE @idKategorii INT;
		DECLARE @idTowaru INT;

        SELECT @idKategorii = MAX(id_kategorie) + 1 FROM kategorie;
		SELECT @idTowaru = MAX(id_towary) + 1 FROM towary;


        INSERT INTO kategorie (id_kategorie, nazwa, opis)
        VALUES (@idKategorii, @nazwaKategorii, @opisKategorii);

        INSERT INTO towary (id_towary, nazwa, aktualna_cena, kategorie_id_kategorie)
        VALUES (@idTowaru, @nazwaTowaru, @cena, @idKategorii);

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;

        PRINT 'Wystąpił błąd podczas dodawania kategorii i towaru.';
        PRINT ERROR_MESSAGE();
    END CATCH
END
GO
/****** Object:  DdlTrigger [DDL_Trigger]    Script Date: 24.05.2024 19:38:04 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TRIGGER [DDL_Trigger]
ON DATABASE
FOR CREATE_TABLE, ALTER_TABLE, DROP_TABLE
AS
BEGIN
    DECLARE @event_data XML
    SET @event_data = EVENTDATA()

    INSERT INTO ddl_log (event_type, object_name, object_type, sql_command)
    VALUES (
        @event_data.value('(/EVENT_INSTANCE/EventType)[1]', 'NVARCHAR(100)'),
        @event_data.value('(/EVENT_INSTANCE/ObjectName)[1]', 'NVARCHAR(255)'),
        @event_data.value('(/EVENT_INSTANCE/ObjectType)[1]', 'NVARCHAR(255)'),
        @event_data.value('(/EVENT_INSTANCE/TSQLCommand)[1]', 'NVARCHAR(MAX)')
    );
END;
GO
ENABLE TRIGGER [DDL_Trigger] ON DATABASE
GO
USE [master]
GO
ALTER DATABASE [projekt] SET  READ_WRITE 
GO
