<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
	<xsl:output method="xml"/>
	
	<xsl:template match="*|/">
		<xsl:apply-templates select="//Package"/>
	</xsl:template>
	<xsl:template match="Package">
		<xsl:for-each select="ConfirmWHDocReg">
			<CONFIRMWHDOCREGTYPE xmlns:doc="https://imsnova.ru/documents" doc:CfgName="ConfirmWHDocReg.cfg.xml">
				<CONFIRMWHDOCREGTYPE_ITEM>
					<xsl:variable name="RegDocDat" select="concat(substring(RegNumberDoc/RegistrationDate,9,2),substring(RegNumberDoc/RegistrationDate,6,2),substring(RegNumberDoc/RegistrationDate,3,2))"/>
					<DocumentID><xsl:value-of select="RegNumberDoc/CustomsCode"/>/<xsl:value-of select="$RegDocDat"/>/<xsl:value-of select="RegNumberDoc/GTDNumber"/></DocumentID>
					<RegDate><xsl:value-of select="RegDate"/></RegDate>
					<RegTime><xsl:value-of select="RegTime"/></RegTime>
					<PresentDate><xsl:value-of select="PresentDate"/></PresentDate>
					<PresentTime><xsl:value-of select="PresentTime"/></PresentTime>					
					<Deadline><xsl:value-of select="Deadline"/></Deadline>
					<MeasuresEnsure><xsl:value-of select="MeasuresEnsure"/></MeasuresEnsure>
					<CustomsOfficeIdentifier><xsl:value-of select="Customs/Code"/></CustomsOfficeIdentifier>
					<CustomsOfficeName><xsl:value-of select="Customs/OfficeName"/></CustomsOfficeName>
					<xsl:for-each select="Organization">
						<Organization_Name><xsl:value-of select="OrganizationName"/></Organization_Name>
						<Organization_ShortName><xsl:value-of select="ShortName"/></Organization_ShortName>
						<Organization_OGRN><xsl:value-of select="RFOrganizationFeatures/OGRN"/></Organization_OGRN>
						<Organization_INN>
							<xsl:choose>
								<xsl:when test="string-length(RFOrganizationFeatures/INN)>0">
									<xsl:value-of select="RFOrganizationFeatures/INN"/>
								</xsl:when>
								<xsl:when test="string-length(RKOrganizationFeatures/IIN)>0">
									<xsl:value-of select="RKOrganizationFeatures/IIN"/>
								</xsl:when>
								<xsl:when test="string-length(RBOrganizationFeatures/UNP)>0">
									<xsl:value-of select="RBOrganizationFeatures/UNP"/>
								</xsl:when>
							</xsl:choose>
						</Organization_INN>
						<Organization_KPP><xsl:value-of select="RFOrganizationFeatures/KPP"/></Organization_KPP>
					</xsl:for-each>
					<xsl:for-each select="CustomsPerson">
						<CustomsPersonName><xsl:value-of select="PersonName"/></CustomsPersonName>
						<CustomsPersonSurname><xsl:value-of select="PersonSurname"/></CustomsPersonSurname>
						<CustomsPersonPost><xsl:value-of select="PersonPost"/></CustomsPersonPost>
						<CustomsPersonLNP><xsl:value-of select="LNP"/></CustomsPersonLNP>
						<CustomsPersonCustomsCode><xsl:value-of select="CustomsCode"/></CustomsPersonCustomsCode>
					</xsl:for-each>
					<xsl:for-each select="RegNumberDoc">
						<RegNum_CustomsCode><xsl:value-of select="CustomsCode"/></RegNum_CustomsCode>
						<RegNum_RegistrationDate><xsl:value-of select="RegistrationDate"/></RegNum_RegistrationDate>
						<RegNum_GTDNumber><xsl:value-of select="GTDNumber"/></RegNum_GTDNumber>
					</xsl:for-each>
					<xsl:for-each select="WarehouseLicense">
						<CertificateNumber><xsl:value-of select="CertificateNumber"/></CertificateNumber>
						<CertificateDate><xsl:value-of select="CertificateDate"/></CertificateDate>
					</xsl:for-each>
				</CONFIRMWHDOCREGTYPE_ITEM>
			</CONFIRMWHDOCREGTYPE>
		</xsl:for-each>
	</xsl:template>
</xsl:stylesheet>