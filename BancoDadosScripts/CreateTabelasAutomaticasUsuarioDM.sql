DECLARE @CreateJobDC nvarchar(4000)
DECLARE @HostName varchar(100)
DECLARE @JobId varchar(100)
DECLARE @StratDate Varchar(10)
DECLARE @StratTime Varchar(10)
DECLARE @MinutoCont INT
DECLARE @TX00 Nvarchar(max)
DECLARE @Mcont INT
DECLARE @McontVirgula INT
DECLARE @MconPonto INT
DECLARE @Nome Nvarchar(max)


SELECT @StratTime = REPLACE(CONVERT(VARCHAR(10), DATEADD(HOUR,4,GETDATE()) , 108),':','')
SELECT @StratDate = REPLACE(CONVERT(VARCHAR(10),GETDATE(), 111),'/','')

DECLARE db_for CURSOR FOR

	SELECT REPLACE([HostName],'-','') FROM [AD].[STGADDomainController]

OPEN db_for 

FETCH NEXT FROM db_for INTO @HostName

WHILE @@FETCH_STATUS = 0
BEGIN

		SET @Mcont = (SELECT LEN(@HostName))

		SET @MconPonto = CHARINDEX('.', @HostName)

		SET @MconPonto = @MconPonto - 1

		SET @TX00 = LEFT(@HostName, @MconPonto)


--SET @CreateJobDC =  'DROP TABLE [AD].[STGADUser'+ @TX00 +']'

SET @CreateJobDC = 'CREATE TABLE [AD].[STGADUser'+ @TX00 +'](
	[idSTGADUser'+ @TX00 +'] [int] IDENTITY(1,1) NOT NULL,
	[SamAccountName] [varchar](100) NULL,
	[PasswordLastSet] [datetime] NULL,
	[LastLogonDate] [datetime] NULL,
	[LastUpdateEtl] [datetime] NULL,
 CONSTRAINT [PK_idSTGADUser'+ @TX00 +'] PRIMARY KEY CLUSTERED 
(
	[idSTGADUser'+ @TX00 +'] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] 


ALTER TABLE [AD].[STGADUser'+ @TX00 +'] ADD  DEFAULT (getdate()) FOR [LastUpdateEtl]

'



 --PRINT @CreateJobDC

 exec sp_executesql @CreateJobDC

	FETCH NEXT FROM db_for INTO @HostName
END

CLOSE db_for
DEALLOCATE db_for
