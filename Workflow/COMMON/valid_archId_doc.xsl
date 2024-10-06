<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
	<xsl:variable name="results-that-is-correct" select="//DesNotif_PIResult_ITEM[ string-length(ArchID)>0 and string-length(DocumentID)>0 ]"/>
	<xsl:template name="validId_doc">
		<xsl:for-each select="/Package/*[string-length(@arch:customsCode)>0]"  xmlns:arch="http://archive.ru">
			<xsl:variable name="queries-was-sent" select="concat(@arch:docCode,@arch:InvDocNumber,substring(@arch:InvDocDate,1,10))" xmlns:arch="http://archive.ru"/>
			<xsl:variable name="results" select="count($results-that-is-correct[concat(InvDocCode,InvDocNumber,substring(InvDocDate,1,10))=$queries-was-sent])"/>
			<xsl:choose>
				<xsl:when test="string-length($queries-was-sent)>0 and $results>0 ">0</xsl:when>
				<xsl:otherwise>1</xsl:otherwise>
			</xsl:choose>
		</xsl:for-each>
	</xsl:template>
</xsl:stylesheet>
