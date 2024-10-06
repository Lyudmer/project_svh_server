<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
	<xsl:param name="ns-map"/>
	<xsl:param name="old-ns1"/>
	<xsl:param name="new-ns1"/>
	<xsl:param name="new-ns-name1"/>
	<xsl:template mode="copy-to-ns" match="/">
		<xsl:copy>
			<xsl:apply-templates/>
		</xsl:copy>
	</xsl:template>
	<xsl:template mode="copy-to-ns" match="comment()|processing-instruction()">
		<xsl:copy/>
	</xsl:template>
	<xsl:template name="copy-to-ns--empty-element-trick">
		<xsl:if test="not(node())">
			<!--трюк: в конечных пустых элементах закрывающий тэг на той же строке, что открывающий-->
			<xsl:text/>
		</xsl:if>
	</xsl:template>
	<xsl:template name="copy-to-ns--childs">
		<xsl:param name="ns-map"/>
		<xsl:param name="old-ns1"/>
		<xsl:param name="new-ns1"/>
		<xsl:param name="new-ns-name1"/>
		<xsl:apply-templates mode="copy-to-ns" select="@*"/>
		<xsl:call-template name="copy-to-ns--empty-element-trick"/>
		<xsl:apply-templates mode="copy-to-ns" select="node()">
			<xsl:with-param name="ns-map" select="$ns-map"/>
			<xsl:with-param name="old-ns1" select="$old-ns1"/>
			<xsl:with-param name="new-ns1" select="$new-ns1"/>
			<xsl:with-param name="new-ns-name1" select="$new-ns-name1"/>
		</xsl:apply-templates>
	</xsl:template>
	<xsl:template mode="copy-to-ns" match="*">
		<xsl:param name="ns-map"/>

		<xsl:variable name="current-ns" select="namespace-uri()"/>
		<xsl:variable name="matched-map" select="$ns-map/map[ @old-ns = $current-ns ]"/>
		<xsl:variable name="is-matched-map" select="count($matched-map) > 0"/>
		<xsl:variable name="matched-new-ns" select="$matched-map/@new-ns"/>
		<xsl:variable name="new-ns">
			<xsl:choose>
				<xsl:when test="$is-matched-map">
					<xsl:value-of select="$matched-new-ns"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="$current-ns"/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<xsl:variable name="matched-new-ns-name" select="$matched-map/@new-ns-name"/>
		<xsl:variable name="new-ns-name">
			<xsl:choose>
				<xsl:when test="$is-matched-map">
					<xsl:choose>
						<xsl:when test="string($matched-new-ns-name)">
							<xsl:value-of select="concat($matched-new-ns-name, ':', local-name())"/>
						</xsl:when>
						<xsl:otherwise>
							<xsl:value-of select="name()"/>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="name()"/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<xsl:if test="count($matched-map) > 1">
			<xsl:message terminate="yes">copy-to-ns: Error dupliсated value '<xsl:value-of select="$current-ns"/>' of @old-ns in $ns-map nodeset. There is <xsl:value-of select="count($matched-map)"/> matches of it and no sense to do. Should be 0 or 1 match of any namespace in @old-ns of $ns-map nodeset.</xsl:message>
		</xsl:if>
		<xsl:element name="{$new-ns-name}" namespace="{$new-ns}">
			<xsl:call-template name="copy-to-ns--childs">
				<xsl:with-param name="ns-map" select="$ns-map"/>
			</xsl:call-template>
		</xsl:element>
	</xsl:template>
	<xsl:template mode="copy-to-ns" match="@*">
		<xsl:copy/>
	</xsl:template>
</xsl:stylesheet>
