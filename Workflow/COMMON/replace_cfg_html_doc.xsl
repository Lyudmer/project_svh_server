<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
	<xsl:import href="copy.xsl"/>
	<xsl:output method="xml"/>
	<xsl:param name="NameCfg"/>
	<xsl:param name="NameNode"/>
	<xsl:param name="DocumentModeID"/>
	<xsl:param name="OldNameCfg"/>
	<xsl:param name="ParentNameNode"/>
	<xsl:template match="/">
		<xsl:choose>
			<xsl:when test="string-length($OldNameCfg)>0 and string-length($ParentNameNode)>0">
				<xsl:apply-templates select="//*[contains(@*[local-name()='CfgName'],$OldNameCfg)][descendant::*[local-name()=$NameNode]]"/>
			</xsl:when>
			<xsl:when test="string-length($OldNameCfg)>0">
				<xsl:apply-templates select="//*[local-name()=$NameNode][contains(@*[local-name()='DocumentModeID'],$DocumentModeID)][contains(@*[local-name()='CfgName'],$OldNameCfg)]"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:apply-templates select="//*[local-name()=$NameNode][contains(@*[local-name()='DocumentModeID'],$DocumentModeID)]"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	<xsl:template match="@*[local-name()='CfgName']" xmlns:docs="https://documents.ru">
		<xsl:attribute name="docs:CfgName"><xsl:value-of select="$NameCfg"/></xsl:attribute>
	</xsl:template>
	<xsl:template match="@*[local-name()='DocumentModeID'][string-length(../@*[local-name()='CfgName'])=0]" xmlns:docs="https://documents.ru">
		<xsl:copy-of select="."/>
		<xsl:attribute name="docs:CfgName"><xsl:value-of select="$NameCfg"/></xsl:attribute>
	</xsl:template>
</xsl:stylesheet>
