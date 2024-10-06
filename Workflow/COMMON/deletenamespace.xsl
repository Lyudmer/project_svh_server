<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:fo="http://www.w3.org/1999/XSL/Format">
<xsl:output method="xml" indent="no"/>

<xsl:template match="/|comment()|processing-instruction()">
    <xsl:copy>
      <xsl:apply-templates/>
    </xsl:copy>
</xsl:template>

<xsl:template match="*">
	<xsl:choose>
		<xsl:when test="local-name()='DocumentID' and contains(name(),':') and not(starts-with(name(),'cat_ru:'))">
			<xsl:variable name="node_name" select="concat(substring-before(name(),':'),substring-after(name(),':'))"/>
			<xsl:element name="{$node_name}">
				<xsl:apply-templates select="@*|node()"/>
			</xsl:element>
		</xsl:when>
		<xsl:otherwise>
		    <xsl:element name="{local-name()}">
				<xsl:apply-templates select="@*|node()"/>
			</xsl:element>
		</xsl:otherwise>
	</xsl:choose>
</xsl:template>

<xsl:template match="@*">
    <xsl:attribute name="{local-name()}">
      <xsl:value-of select="."/>
    </xsl:attribute>
</xsl:template>
  
</xsl:stylesheet>
