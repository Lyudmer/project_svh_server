<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
	<xsl:output method="xml"/>
	<xsl:template match="*|/">
		<xsl:apply-templates select="//*[local-name()='ArchResult'][position()=last()]"/>
	</xsl:template>
	<xsl:template match="*[local-name()='ArchResult'][position()=last()]">
		<DesNotif_PIResult>
			<DesNotif_PIResult_ITEM>
				<ResultInformation>
					<xsl:for-each select="*[local-name()='ResultInformation']">
						<RESULTINFORMATION_ITEM>
							<ResultCode><xsl:value-of select="*[local-name()='ResultCode']"/></ResultCode>
							<ResultIdDocument><xsl:value-of select="../*[local-name()='DocumentID']"/></ResultIdDocument>
							<ArchID><xsl:value-of select="*[local-name()='ArchID']"/></ArchID>
							<ArchDocID><xsl:value-of select="*[local-name()='ArchDocID']"/></ArchDocID>
							<InvDocCode><xsl:value-of select="*[local-name()='DocCode']"/></InvDocCode>
							<InvDocNumber><xsl:value-of select="*[local-name()='DocNum']"/></InvDocNumber>
							<InvDocDate><xsl:value-of select="*[local-name()='DocDate']"/></InvDocDate>
						</RESULTINFORMATION_ITEM>
					</xsl:for-each>
				</ResultInformation>
			</DesNotif_PIResult_ITEM>
		</DesNotif_PIResult>
	</xsl:template>	

</xsl:stylesheet>
