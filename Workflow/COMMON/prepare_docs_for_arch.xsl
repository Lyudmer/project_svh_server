<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:arch="http://archive.ru">
	<xsl:param name="customsCode"/>
	<xsl:template match="//*">
		<xsl:choose>
			<xsl:when test="local-name()='TextSection' and local-name(parent::*)='DocumentBody' and *[local-name()='SectionName']='ModeCode'"/>
			<xsl:otherwise>
				<xsl:copy>
					<xsl:apply-templates select="@*"/>
					<xsl:if test="@DocumentModeID">
						<xsl:choose>
							<xsl:when test="@DocumentModeID='1003202E'">
								<xsl:attribute name="arch:docCode">02011</xsl:attribute>
								<xsl:attribute name="arch:InvDocNumber"><xsl:value-of select="*[local-name()='RegistrationDocument']/*[local-name()='PrDocumentNumber']"/></xsl:attribute>
								<xsl:if test="string-length(*[local-name()='RegistrationDocument']/*[local-name()='PrDocumentDate'])>0">
									<xsl:attribute name="arch:InvDocDate"><xsl:value-of select="*[local-name()='RegistrationDocument']/*[local-name()='PrDocumentDate']"/></xsl:attribute>
								</xsl:if>
							</xsl:when>
							<xsl:when test="@DocumentModeID='1006003E' or @DocumentModeID='1008014E' or @DocumentModeID='1006146E'"/>
							<xsl:otherwise>
								<xsl:message terminate="yes">Отправка в архив РТУ: неподдерживаемый тип документа <xsl:value-of select="concat(local-name(),' ',@DocumentModeID)"/>
								</xsl:message>
							</xsl:otherwise>
						</xsl:choose>
						<xsl:attribute name="arch:customsCode"><xsl:value-of select="normalize-space($customsCode)"/></xsl:attribute>
					</xsl:if>
					<xsl:apply-templates select="text()|*"/>
				</xsl:copy>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	<xsl:template match="/|*|text()|@*">
		<xsl:copy>
			<xsl:apply-templates select="*|text()|@*"/>
		</xsl:copy>
	</xsl:template>
</xsl:stylesheet>
