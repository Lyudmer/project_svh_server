<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
	<xsl:import href="../COMMON/function_for_server.xsl"/>
	<xsl:import href="ArmtiEDContainerConosament.xsl"/>
	<xsl:import href="ArmtiEDContainerWHDocInventory.xsl"/>
	<xsl:output method="xml"/>
	<xsl:template match="/">
		<ED_Container xmlns="urn:customs.ru:Information:ExchangeDocuments:ED_Container:5.24.0" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" DocumentModeID="1006058E">
			<cat_ru:DocumentID xmlns:cat_ru="urn:customs.ru:CommonAggregateTypes:5.24.0">00000000-0000-0000-0000-000000000000</cat_ru:DocumentID>
			<xsl:variable name="RefDocumentID" select="package-properties/prop[@name='RefDocumentID']"/>
			<xsl:if test="string-length($RefDocumentID)>0">
				<cat_ru:RefDocumentID xmlns:cat_ru="urn:customs.ru:CommonAggregateTypes:5.24.0">
					<xsl:value-of select="$RefDocumentID"/>
				</cat_ru:RefDocumentID>
			</xsl:if>
			<xsl:for-each select="//CONOSAMENT/CONOSAMENT_ITEM">
				<xsl:call-template name="CONOSAMENT"/>
			</xsl:for-each>	
			<xsl:apply-templates select="//ARRSEADECLGOODS_ITEM[generate-id(.)=generate-id(key('ConosamentArrDcl',./ConosamentNum))]">
				<xsl:with-param name="ArrSeaD"  select="1"/>
			</xsl:apply-templates>
			<ContainerDoc xmlns="urn:customs.ru:Information:ExchangeDocuments:ED_Container:5.24.0">
				<DocBody>
					<xsl:call-template name="whInventory-armti"/>
				</DocBody>
			</ContainerDoc>
		</ED_Container>
	</xsl:template>
</xsl:stylesheet>
