<?xml version="1.0" encoding="UTF-8"?>
<!-- edited with XMLSpy v2015 sp2 (http://www.altova.com) by Anand (Home) -->
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
	<xsl:template match="/">
		<xsl:copy>
			<xsl:apply-templates/>
		</xsl:copy>
	</xsl:template>
	<xsl:template match="comment()|processing-instruction()">
		<xsl:copy/>
	</xsl:template>
	<xsl:template name="copy-empty-element-trick">
		<xsl:if test="not(node())">
			<!--трюк: в конечных элементах закрывающий тэг на той же строке, что открывающий-->
			<xsl:text/>
		</xsl:if>
	</xsl:template>
	<xsl:template name="copy-content">
		<xsl:apply-templates select="@*"/>
		<xsl:call-template name="copy-empty-element-trick"/>
		<xsl:apply-templates select="node()"/>
	</xsl:template>
	<xsl:template match="*" name="match-element">
		<xsl:copy>
			<xsl:call-template name="copy-content"/>
		</xsl:copy>
	</xsl:template>
	<xsl:template match="@*">
		<xsl:copy/>
	</xsl:template>
</xsl:stylesheet>
