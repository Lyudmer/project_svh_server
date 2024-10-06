<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

	<xsl:output method="xml"/>
	<xsl:param name="copy_all_doc"/>
	
	<xsl:template match="*|/">
		<xsl:apply-templates select="//ConfirmWHDocReg"/>
	</xsl:template>

	<xsl:template match="@*|node()">
		<xsl:copy>
			<xsl:apply-templates select="@*|node()"/>
		</xsl:copy>
	</xsl:template>
	<xsl:template match="CONFIRMWHDOCREGTYPE"/>
	
	<xsl:template match="ConfirmWHDocReg">
		<CONFIRMWHDOCREGTYPE xmlns:docs="https://documents" docs:CfgName="ConfirmWHDocReg.cfg.xml">
			<CONFIRMWHDOCREGTYPE_ITEM>
				<xsl:variable name="RegDocDat" select="concat(substring(RegNumberDoc/RegistrationDate,9,2),substring(RegNumberDoc/RegistrationDate,6,2),substring(RegNumberDoc/RegistrationDate,3,2))"/>
				<DocumentID><xsl:value-of select="RegNumberDoc/CustomsCode"/>/<xsl:value-of select="$RegDocDat"/>/<xsl:value-of select="RegNumberDoc/GTDNumber"/></DocumentID>
				<RefDocumentID><xsl:value-of select="RefDocumentID"/></RefDocumentID>
				<RegDate><xsl:value-of select="RegDate"/></RegDate>
				<RegTime><xsl:value-of select="RegTime"/></RegTime>
				<PresentDate><xsl:value-of select="PresentDate"/></PresentDate>
				<PresentTime><xsl:value-of select="PresentTime"/></PresentTime>
				<Deadline><xsl:value-of select="Deadline"/></Deadline>
				<MeasuresEnsure><xsl:value-of select="MeasuresEnsure"/></MeasuresEnsure>
				<xsl:apply-templates select="Customs"/>
				<xsl:apply-templates select="Organization"/>
				<xsl:apply-templates select="CustomsPerson"/>
				<xsl:apply-templates select="RegNumberDoc"/>
				<xsl:apply-templates select="WarehouseLicense"/>
			</CONFIRMWHDOCREGTYPE_ITEM>
		</CONFIRMWHDOCREGTYPE>
	</xsl:template>
	
	<xsl:template match="Customs">
		<CustomsOfficeIdentifier><xsl:value-of select="Code"/></CustomsOfficeIdentifier>
		<CustomsOfficeName><xsl:value-of select="OfficeName"/></CustomsOfficeName>
	</xsl:template>
	
	<xsl:template match="Organization">
		<Organization_Name><xsl:value-of select="OrganizationName"/></Organization_Name>
		<Organization_ShortName><xsl:value-of select="ShortName"/></Organization_ShortName>
		<xsl:if test="string-length(RFOrganizationFeatures/INN)>0">
			<Organization_OGRN><xsl:value-of select="RFOrganizationFeatures/OGRN"/></Organization_OGRN>
			<Organization_INN><xsl:value-of select="RFOrganizationFeatures/INN"/></Organization_INN>
			<Organization_KPP><xsl:value-of select="RFOrganizationFeatures/KPP"/></Organization_KPP>
		</xsl:if>
		<xsl:if test="string-length(RKOrganizationFeatures/IIN)>0">
			<Organization_INN><xsl:value-of select="RKOrganizationFeatures/IIN"/></Organization_INN>
		</xsl:if>
		<xsl:if test="string-length(RBOrganizationFeatures/RBIdentificationNumber)>0">
			<Organization_INN><xsl:value-of select="RBOrganizationFeatures/RBIdentificationNumber"/></Organization_INN>
		</xsl:if>
	</xsl:template>	
	
	<xsl:template match="CustomsPerson">
		<CustomsPersonName><xsl:value-of select="PersonName"/></CustomsPersonName>
		<CustomsPersonSurname><xsl:value-of select="PersonSurname"/></CustomsPersonSurname>
		<CustomsPersonMiddleName><xsl:value-of select="PersonMiddleName"/></CustomsPersonMiddleName>
		<CustomsPersonPost><xsl:value-of select="PersonPost"/></CustomsPersonPost>
		<CustomsPersonLNP><xsl:value-of select="LNP"/></CustomsPersonLNP>
	</xsl:template>
	
	<xsl:template match="RegNumberDoc">
		<RegNum_CustomsCode><xsl:value-of select="CustomsCode"/></RegNum_CustomsCode>
		<RegNum_RegistrationDate><xsl:value-of select="RegistrationDate"/></RegNum_RegistrationDate>
		<RegNum_GTDNumber><xsl:value-of select="GTDNumber"/></RegNum_GTDNumber>
	</xsl:template>
	<xsl:template match="WarehouseLicense">
		<CertificateNumber><xsl:value-of select="CertificateNumber"/></CertificateNumber>
		<CertificateDate><xsl:value-of select="CertificateDate"/></CertificateDate>
	</xsl:template>
	
	</xsl:stylesheet>
