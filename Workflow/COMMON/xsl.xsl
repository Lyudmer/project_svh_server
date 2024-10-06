<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
	<xsl:key name="xsl-value-of-const" use="concat('$', ancestor-or-self::xsl:variable/@name)" match="/*/xsl:variable/@select | /*/xsl:variable[ not(@select) ]"/>
	<xsl:key name="xsl-const-name-of-value" use="concat(parent::*/@select, string(parent::*))" match="/*/xsl:variable/@name"/>
</xsl:stylesheet>
