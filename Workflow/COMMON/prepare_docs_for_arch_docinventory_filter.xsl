<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
	<xsl:output method="xml" version="1.0" encoding="UTF-8" indent="yes"/>
	<xsl:template match="/">
		<xsl:copy>
			<xsl:apply-templates/>
		</xsl:copy>
	</xsl:template>
	<xsl:template match="*">
		<xsl:choose>
			<xsl:when test="*[local-name()='BillofLading'] or *[local-name()='WHDocInventory']">
				<xsl:copy-of select="."/> 
			</xsl:when>
			<xsl:when  test="normalize-space(.//text())">
				<xsl:copy>
					<xsl:copy-of select="@*"/>
					<xsl:apply-templates select="node()"/>
				</xsl:copy>
			</xsl:when>
		</xsl:choose> 
	</xsl:template>
</xsl:stylesheet>
