<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
	<xsl:output method="xml"/>
	<xsl:template match="*|/">
		<xsl:apply-templates select="//*[local-name()='ErrorList'][position()=last()]"/>
	</xsl:template>
	<xsl:template match="*[local-name()='ErrorList'][position()=last()]">
		<xsl:variable name="DocError">
			<xsl:call-template name="ErrorDocName">
				<xsl:with-param name="NodeName" select="*[local-name()='BadDocument']/*[local-name()='DocName']"/>
			</xsl:call-template>	
		</xsl:variable>			
		<DesNotif_PIResult xmlns:docs="https://documents.ru" docs:CfgName="desnotif_piresult.cfg.xml">
			<DesNotif_PIResult_ITEM>
				<ResultInformation>
					<xsl:for-each select="*[local-name()='BadDocument']/*[local-name()='Error']">
						<RESULTINFORMATION_ITEM>
							<ResultCode><xsl:value-of select="*[local-name()='ErrCode']"/></ResultCode>
							<ResultDescription>
								<xsl:if test="string-length($DocError)>0">
									<xsl:text>Документ</xsl:text>
									<xsl:value-of select="$DocError"/>
								</xsl:if>
								<xsl:value-of select="*[local-name()='ErrorName']"/>
								<xsl:text> </xsl:text>
								<xsl:value-of select="*[local-name()='ErrDescription']"/>
								<xsl:text> </xsl:text>
								<xsl:value-of select="*[local-name()='ErrElementDesc']"/>
								<xsl:text> </xsl:text>
								<xsl:value-of select="*[local-name()='CorrectValue']"/>
								<xsl:text> </xsl:text>
							</ResultDescription>
							<ResultCategory>ERROR</ResultCategory>
							<ResultIdDocument><xsl:value-of select="../*[local-name()='DocID']"/></ResultIdDocument>
							<ResultPathNode><xsl:value-of select="*[local-name()='ErrElement']"/></ResultPathNode>
						</RESULTINFORMATION_ITEM>
					</xsl:for-each>
				</ResultInformation>
			</DesNotif_PIResult_ITEM>
		</DesNotif_PIResult>
	</xsl:template>	
	<xsl:template name="ErrorDocName">
		<xsl:param name="NodeName"/>
		<xsl:choose>
			<xsl:when test="$NodeName='BillofLading'"> Коносамент </xsl:when>
			<xsl:when test="$NodeName='ArrivalDepartCargoDecl'"> Декларация о грузе при приходе/отходе судна </xsl:when>
		</xsl:choose>
	</xsl:template>
</xsl:stylesheet>
