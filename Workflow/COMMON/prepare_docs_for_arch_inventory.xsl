<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:arch="http://archive.ru">
	<xsl:template match="*[local-name()='ContainerDoc'][*[local-name()='DocBody']/*[@DocumentModeID and not(@DocumentModeID = '1006058E')]]">
		<xsl:for-each select="*/*">
			<xsl:call-template name="output-attributes"/>
		</xsl:for-each>
	</xsl:template>
	<xsl:template match="/|*|text()|@*">
		<xsl:copy>
			<xsl:apply-templates select="*|text()|@*"/>
		</xsl:copy>
	</xsl:template>
	<xsl:template name="output-attributes">
		<xsl:variable name="InvDocCode-default" select="@arch:docCode"/>
		<xsl:variable name="InvDocName-default" select="@arch:InvDocName"/>
		<xsl:variable name="InvDocNumber" select="@arch:InvDocNumber"/>
		<xsl:variable name="InvDocDate" select="@arch:InvDocDate"/>
		<xsl:variable name="key-use">
			<xsl:variable name="key-use-InvDocNameCode" select="concat($InvDocCode-default,$InvDocName-default,$InvDocNumber,$InvDocDate )"/>
			<xsl:variable name="key-use-NumberCode" select="concat($InvDocCode-default,$InvDocNumber,$InvDocDate )"/>
			<xsl:variable name="key-use-InvDocName" select="concat($InvDocName-default,$InvDocNumber,$InvDocDate )"/>
			<xsl:variable name="key-use-InvDocCodeNum" select="concat($InvDocCode-default,$InvDocNumber)"/>
			<xsl:variable name="key-use-Number" select="concat($InvDocNumber,$InvDocDate )"/>
			<xsl:choose>
				<xsl:when test="string-length($InvDocCode-default)>0   and string-length($InvDocName-default)>0  and  count(key('InvDocCode', $key-use-InvDocNameCode)) > 0">
					<xsl:value-of select="$key-use-InvDocNameCode"/>
				</xsl:when>
				<xsl:when test="string-length($InvDocCode-default)>0   and string-length($InvDocName-default)=0   and   count(key('InvDocCode', $key-use-NumberCode)) > 0">
					<xsl:value-of select="$key-use-NumberCode"/>
				</xsl:when>
				<xsl:when test="string-length($InvDocCode-default)>0 and string-length($InvDocName-default)=0   and string-length($InvDocNumber)>0  and not(contains(local-name(),'FreeBinaryDoc')) and   count(key('InvDocCode', $key-use-InvDocCodeNum)) > 0">
					<xsl:value-of select="$key-use-InvDocCodeNum"/>
				</xsl:when>
				<xsl:when test="string-length($InvDocName-default)>0   and   count(key('InvDocCode', $key-use-InvDocName)) > 0">
					<xsl:value-of select="$key-use-InvDocName"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="$key-use-Number"/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<xsl:variable name="InvDocCode" select="key('InvDocCode', $key-use)"/>
		<xsl:variable name="InvDocCode-Name" select="$InvDocCode/../*[ local-name() = 'InvDocName' ]"/>
		<xsl:variable name="InvDocCode-DocSign" select="$InvDocCode/../*[  local-name() = 'DocumentFormSign' ]"/>
		<xsl:variable name="InvDocDate-human" select="concat( 'от ', substring($InvDocDate, 9, 2), '.', substring($InvDocDate, 6, 2), '.', substring($InvDocDate, 1, 4) )"/>
		<xsl:variable name="doc-num-human">
			<xsl:variable name="doc-num-human1" select="concat($InvDocName-default, ' ', $InvDocNumber, ' ', $InvDocDate-human)"/>
			<xsl:value-of select="$doc-num-human1"/>
			<xsl:if test="not(string(normalize-space($doc-num-human1)))">
				<xsl:value-of select="concat('(', name(), '[', 1 + count(preceding-sibling::*), '][', @DocumentModeID, '])')"/>
			</xsl:if>
		</xsl:variable>
		<xsl:choose>
			<xsl:when test="number($InvDocCode-DocSign)=1">
			</xsl:when>
			<xsl:otherwise>
				<xsl:for-each select="../parent::*">
					<xsl:copy>
						<xsl:for-each select="*">
							<xsl:copy>
								<xsl:for-each select="*">
									<xsl:copy>
										<xsl:apply-templates select="@*"/>
										<xsl:choose>
											<xsl:when test="0 = count($InvDocCode)">
												<xsl:message terminate="yes">
													<xsl:text>Необходимо заполнить в описи код документа либо добавить документ в опись </xsl:text>
													<xsl:value-of select="$doc-num-human"/>
												</xsl:message>
											</xsl:when>
											<xsl:when test="$InvDocCode != $InvDocCode">
												<xsl:message terminate="yes">
													<xsl:if test="$Inventory-count > 1">
														В пакете должна быть одна опись, а не <xsl:value-of select="$Inventory-count"/>. 
													</xsl:if>
														В пакете и в Описи несколько одинаковых документов (<xsl:value-of select="count($InvDocCode)"/>) 
													<xsl:value-of select="$doc-num-human"/>
												</xsl:message>
											</xsl:when>
											<xsl:when test="$InvDocCode = $InvDocCode-default">
											</xsl:when>
											<xsl:otherwise>
												<xsl:attribute name="fb:docCode"><xsl:value-of select="$InvDocCode"/></xsl:attribute>
											</xsl:otherwise>
										</xsl:choose>
										<xsl:if test="not(string($InvDocName-default)) and count($InvDocCode) = 1 and string($InvDocCode-Name)">
											<xsl:attribute name="arch:InvDocName"><xsl:value-of select="$InvDocCode-Name"/></xsl:attribute>
										</xsl:if>
										<xsl:apply-templates select="text()|*"/>
									</xsl:copy>
								</xsl:for-each>
							</xsl:copy>
						</xsl:for-each>
					</xsl:copy>
				</xsl:for-each>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	<xsl:key name="InvDocCode" use="concat(../*[ local-name() = 'InvDocCode' ], ../*[ local-name() = 'InvDocName' ],  ../*[ local-name() = 'InvDocNumber' ],  ../*[ local-name() = 'InvDocDate' ])" match="*[ local-name() = 'Inventory' and @DocumentModeID = '1006003E' ]/*[ local-name() = 'InventoryInstance' ]/*[ local-name() = 'InventDocument' ]/*[ local-name() = 'InvDocCode' ][ string() ]"/>
	<xsl:key name="InvDocCode" use="concat(../*[ local-name() = 'InvDocCode' ], ../*[ local-name() = 'InvDocNumber' ], ../*[ local-name() = 'InvDocDate' ] )" match="*[ local-name() = 'Inventory' and @DocumentModeID = '1006003E' ]/*[ local-name() = 'InventoryInstance' ]/*[ local-name() = 'InventDocument' ]/*[ local-name() = 'InvDocCode' ][ string() ]"/>
	<xsl:key name="InvDocCode" use="concat(../*[ local-name() = 'InvDocName' ], ../*[ local-name() = 'InvDocNumber' ], ../*[ local-name() = 'InvDocDate' ])" match="*[ local-name() = 'Inventory' and @DocumentModeID = '1006003E' ]/*[ local-name() = 'InventoryInstance' ]/*[ local-name() = 'InventDocument' ]/*[ local-name() = 'InvDocCode' ][ string() ]"/>
	<xsl:key name="InvDocCode" use="concat(../*[ local-name() = 'InvDocCode' ],  ../*[ local-name() = 'InvDocNumber' ])" match="*[ local-name() = 'Inventory' and @DocumentModeID = '1006003E' ]/*[ local-name() = 'InventoryInstance' ]/*[ local-name() = 'InventDocument' ]/*[ local-name() = 'InvDocCode' ][ string() ]"/>
	<xsl:key name="InvDocCode" use="concat(../*[ local-name() = 'InvDocNumber' ], ../*[ local-name() = 'InvDocDate' ] )" match="*[ local-name() = 'Inventory' and @DocumentModeID = '1006003E' ]/*[ local-name() = 'InventoryInstance' ]/*[ local-name() = 'InventDocument' ]/*[ local-name() = 'InvDocCode' ][ string() ]"/>
	<xsl:variable name="Inventory" select="//*[ local-name() = 'Inventory' and @DocumentModeID = '1006003E' ]"/>
	<xsl:variable name="Inventory-count" select="count($Inventory)"/>
	<xsl:template match="//*[ */*[ local-name() = 'Inventory' and @DocumentModeID = '1006003E' ]]">
	</xsl:template>
</xsl:stylesheet>
