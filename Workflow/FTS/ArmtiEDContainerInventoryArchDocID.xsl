<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
	<xsl:variable name="results-that-is-correct" select="//DesNotif_PIResult_ITEM[ string-length(ArchID)>0 and string-length(DocumentID)>0 ]"/>
	<xsl:template mode="Inventory-Arch" match="InventDocument/INVENTDOCUMENT_ITEM" xmlns="urn:customs.ru:Information:CustomsDocuments:Inventory:5.24.0">
		<xsl:param name="namespace-uri"/>
		<xsl:param name="DocCode"/>
		<xsl:call-template name="Inventory-Archid" >
			<xsl:with-param name="InvDocCode" select="$DocCode"/>
			<xsl:with-param name="InvDocNumber" select="InvDocNumber"/>
			<xsl:with-param name="InvDocName"  select="Note"/>
			<xsl:with-param name="InvDocDate" select="InvDocDate"/>
			<xsl:with-param name="namespace-uri" select="$namespace-uri"/>
		</xsl:call-template>
	</xsl:template>
	<xsl:template name="Inventory-Archid" >
		<xsl:param name="InvDocCode"/>
		<xsl:param name="InvDocNumber"/>
		<xsl:param name="InvDocName"/>
		<xsl:param name="InvDocDate"/>
		<xsl:param name="namespace-uri"/>
		<xsl:variable name="queries-was-sent" select="/Package/*[ concat(arch:docCode,arch:InvDocNumber,substring(arch:InvDocDate,1,10))= concat($InvDocCode,$InvDocNumber,substring($InvDocDate,1,10)) ]" xmlns:arch="http://archive.ru"/>
		<xsl:variable name="queries-was-sent-new" select="/Package/*[ concat(arch:docCode,arch:InvDocNumber,arch:InvDocName,substring(arch:InvDocDate,1,10))= concat($InvDocCode,$InvDocNumber,$InvDocName, substring($InvDocDate,1,10)) ]" xmlns:arch="http://archive.ru"/>
		<xsl:variable name="results" select="$results-that-is-correct[concat(InvDocCode,InvDocNumber,substring(InvDocDate,1,10))=concat($InvDocCode,$InvDocNumber,substring($InvDocDate,1,10)) ]"/>
		<xsl:variable name="results-new" select="$results-that-is-correct[concat(InvDocCode,InvDocNumber,InvDocName,substring(InvDocDate,1,10))=concat($InvDocCode,$InvDocNumber,$InvDocName,substring($InvDocDate,1,10)) ]"/>
		
		<xsl:variable name="position-in-equal-siblings" select="1 + count(   preceding-sibling::*[concat(InvDocCode, InvDocNumber , substring(InvDocDate,1,10))=concat($InvDocCode, $InvDocNumber , substring($InvDocDate,1,10)) ]   )"/>
		<xsl:variable name="position-in-equal-siblings-new" select="1 + count(   preceding-sibling::*[concat(InvDocCode, InvDocNumber ,InvDocName, substring(InvDocDate,1,10))=concat($InvDocCode, $InvDocNumber , $InvDocName,substring($InvDocDate,1,10)) ]   )"/>
		
		<xsl:variable name="single-result-in-position" select="$results[ position() = $position-in-equal-siblings ]"/>
		<xsl:variable name="single-result-in-position-new" select="$results-new[ position() = $position-in-equal-siblings-new ]"/>
		
		<xsl:choose>
			<xsl:when test="count($single-result-in-position)>0 and count($single-result-in-position-new)=0">
				<xsl:for-each select="$single-result-in-position[1]">
					<xsl:element name="ArchID" namespace="{$namespace-uri}">
						<xsl:value-of select="ArchID"/>
					</xsl:element>
					<xsl:element name="ArchDocID" namespace="{$namespace-uri}">
						<xsl:value-of select="DocumentID"/>
					</xsl:element>
				</xsl:for-each>
			</xsl:when>
			<xsl:when test="count($single-result-in-position-new)>0">
				<xsl:for-each select="$single-result-in-position-new[1]">
					<xsl:element name="ArchID" namespace="{$namespace-uri}">
						<xsl:value-of select="ArchID"/>
					</xsl:element>
					<xsl:element name="ArchDocID" namespace="{$namespace-uri}">
						<xsl:value-of select="DocumentID"/>
					</xsl:element>
				</xsl:for-each>
			</xsl:when>
			<xsl:when test="0 = count(  $queries-was-sent[ position() = $position-in-equal-siblings ]  ) and 0 = count(  $queries-was-sent-new[ position() = $position-in-equal-siblings-new ]  )">
			</xsl:when>
			<xsl:otherwise>
				<xsl:message terminate="yes">Не нашёлся ответ о размещении документа в таможенном архиве (ArchDocID) для строки из описи: <xsl:value-of select="concat($InvDocCode, ' ', $InvDocNumber, ' ',$InvDocName , ' ',$InvDocDate)"/>
				</xsl:message>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
</xsl:stylesheet>
