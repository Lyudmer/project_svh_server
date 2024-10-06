<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
	<xsl:import href="../COMMON/function_for_server.xsl"/>
	<xsl:import href="ArmtiEDContainerSEA.xsl"/>
	<xsl:import href="ArmtiEDContainerInventoryArchDocID.xsl"/>
	
	<xsl:output method="xml"/>
	<xsl:param name="Now"/>
	
	<xsl:variable name="PathNsiWH" select="document('../NSI/TranspNSIXml.xml')"/>
	<xsl:key use="concat(../ContainerNum,../../../RegNum)" name="ContSeaWH" match="//CONOSAMENTGoods/CONOSAMENTGOODS_ITEM[string-length(ContainerNum)>0]/ContainerNum"/>
	<xsl:key use="concat(../ContainerNum,../../../RegNum,../../../PI_RegID)" name="ContSeaWHUIN" match="//CONOSAMENTGoods/CONOSAMENTGOODS_ITEM[string-length(ContainerNum)>0]/ContainerNum"/>
	<xsl:key use="concat(../ContainerID,../../../ConosamentNum,../../../ConosamentID)" name="ArrDclContSeaWH" match="//ARRSEADECLGOODS_ITEM/Container/CONTAINER_ITEM[string-length(ContainerID)>0]/ContainerID"/>

	
	<xsl:template match="/Package">
		<xsl:apply-templates mode="whInventory-armti" select="WHDOCINVENTORY/WHDOCINVENTORY_ITEM">
			<xsl:with-param name="ArchNum" select="1"/>
		</xsl:apply-templates>
	</xsl:template>
	<xsl:template name="whInventory-armti">
		<xsl:apply-templates mode="whInventory-armti" select="WHDOCINVENTORY/WHDOCINVENTORY_ITEM"/>
	</xsl:template>
	<xsl:template match="WHDOCINVENTORY/WHDOCINVENTORY_ITEM" mode="whInventory-armti">
		<xsl:param name="ArchNum"/>
		<WHDocInventory xmlns="urn:customs.ru:Information:WarehouseDocuments:WHDocInventory:5.24.0" xmlns:catWH_ru="urn:customs.ru:Information:WarehouseDocuments:WarehouseCommonAggregateTypesCust:5.24.0" xmlns:cat_ru="urn:customs.ru:CommonAggregateTypes:5.24.0" DocumentModeID="1008014E">
			<cat_ru:DocumentID>00000000-0000-0000-0000-000000000000</cat_ru:DocumentID>
			<InventoryInstanceDate>
				<xsl:call-template name="TranslateDate">
					<xsl:with-param name="Dat" select="InventoryInstanceDate"/>
				</xsl:call-template>
			</InventoryInstanceDate>
			<xsl:for-each select="InventDocument/INVENTDOCUMENT_ITEM[string-length(InvDocCode)>0]">
				<xsl:variable name="NumDat" select="concat(Note,InvDocNumber,substring(InvDocDate,1,10))"/>	
				<xsl:variable name="Nums" select="InvDocNumber"/>
				<InventDocument>
					<InvDocCode><xsl:value-of select="InvDocCode"/></InvDocCode>
					<xsl:if test="string-length(InvDocNumber)>0">
						<InvDocNumber><xsl:value-of select="InvDocNumber"/></InvDocNumber>
					</xsl:if>
					<xsl:if test="string-length(InvDocDate)>0">	
						<InvDocDate>
							<xsl:call-template name="TranslateDate">
								<xsl:with-param name="Dat"  select="InvDocDate"/>
							</xsl:call-template>
						</InvDocDate>
					</xsl:if>	
					<xsl:if test="string-length(Note)>0">
						<Note><xsl:value-of select="normalize-space(substring(Note,1,250))"/></Note>
					</xsl:if>
					<xsl:if test="$ArchNum=1">
						<xsl:apply-templates mode="Inventory-Arch" select=".">
							<xsl:with-param name="namespace-uri">urn:customs.ru:Information:WarehouseDocuments:WHDocInventory:5.24.0</xsl:with-param>
							<xsl:with-param name="DocCode" select="InvDocCode"/>
						</xsl:apply-templates>
						<InventLineID>00000000-0000-0000-0000-000000000000</InventLineID>
					</xsl:if>
				</InventDocument>
			</xsl:for-each>
			<Sender>
				<xsl:call-template name="FirmCarrier">
					<xsl:with-param name="Pref">Carrier_</xsl:with-param>
					<xsl:with-param name="PrefPerson">Carrier_Driver_</xsl:with-param>
				</xsl:call-template>
			</Sender>
			<Receiver>
				<Customs>
					<cat_ru:Code><xsl:value-of select="Receiver_Customs_Code"/></cat_ru:Code>
					<xsl:if test="string-length(Receiver_Customs_OfficeName)>0">
						<cat_ru:OfficeName><xsl:value-of select="Receiver_Customs_OfficeName"/></cat_ru:OfficeName>
					</xsl:if>
				</Customs>
			</Receiver>
			<xsl:if test="string-length(RegistrationNumber)>0 and substring(RegistrationNumber,1,9)='/' and substring(RegistrationNumber,1,16)='/'">
				<RegNumberDoc>
					<cat_ru:CustomsCode><xsl:value-of select="substring(RegistrationNumber,1,8)"/></cat_ru:CustomsCode>
					<cat_ru:RegistrationDate><xsl:value-of select="concat('20',substring(RegistrationNumber,14,2),'-',substring(RegistrationNumber,12,2),'-',substring(RegistrationNumber,10,2))"/></cat_ru:RegistrationDate>
					<cat_ru:GTDNumber><xsl:value-of select="substring(RegistrationNumber,17)"/></cat_ru:GTDNumber>
				</RegNumberDoc>
			</xsl:if>
			<xsl:call-template name="FirmCarrier">
				<xsl:with-param name="Pref">Participant_</xsl:with-param>
				<xsl:with-param name="PrefPerson">Participant_Ambassador_</xsl:with-param>
			</xsl:call-template>
			<xsl:if test="string-length(CertificateKind)>0 and string-length(CertificateNumber)>0">
				<WarehouseOwner>
				<catWH_ru:Address/>
					<catWH_ru:WarehouseLicense>
					<catWH_ru:CertificateKind>
						<xsl:choose>
								<xsl:when test="CertificateKind=0">lic_Certificate</xsl:when>
								<xsl:when test="CertificateKind=1">lic_Licence</xsl:when>
								<xsl:when test="CertificateKind=2">lic_Permition</xsl:when>
								<xsl:when test="CertificateKind=3">lic_PermZtk</xsl:when>
								<xsl:when test="CertificateKind=4">lic_TempZtk</xsl:when>
							</xsl:choose>
					</catWH_ru:CertificateKind>
					<catWH_ru:CertificateNumber><xsl:value-of select="CertificateNumber"/></catWH_ru:CertificateNumber>
					<xsl:if test="string-length(CertificateDate)>0">
						<catWH_ru:CertificateDate>
							<xsl:call-template name="TranslateDate">
								<xsl:with-param name="Dat"  select="CertificateDate"/>
							</xsl:call-template>	
						</catWH_ru:CertificateDate>
					</xsl:if>
					</catWH_ru:WarehouseLicense>
				</WarehouseOwner>
			</xsl:if>
			<xsl:choose>
				<xsl:when test="count(//ARRSEADECL)>0">
					<xsl:for-each select="//ARRSEADECL/ARRSEADECL_ITEM">
						<Transports>
							<catWH_ru:TransportModeCode>10</catWH_ru:TransportModeCode>
							<catWH_ru:TransportIdentifier><xsl:value-of select="VesselName"/></catWH_ru:TransportIdentifier>
							<catWH_ru:Sea>
								<xsl:if test="string-length(VesselNationalityCountryCode)>0 or (string-length(VesselNationalityCode)>0 and number(VesselNationalityCode)>0)">
									<catWH_ru:CountryCode>
										<xsl:choose>
											<xsl:when test="string-length(VesselNationalityCountryCode)>0">
												<xsl:value-of select="VesselNationalityCountryCode"/>
											</xsl:when>
											<xsl:when test="string-length(VesselNationalityCode)>0 and number(VesselNationalityCode)>0">
												<xsl:variable select="VesselNationalityCode" name="VNCode"/>
												<xsl:value-of select="$PathNsiWH//Country_ITEM[Code=$VNCode]/ABC2"/>
											</xsl:when>
										</xsl:choose>
									</catWH_ru:CountryCode>
								</xsl:if>
								<xsl:if test="string-length(DocSig_PersonName)>0 and string-length(DocSig_PersonName2)>0">
									<catWH_ru:Captain>
										<cat_ru:PersonSurname><xsl:value-of select="DocSig_PersonName"/></cat_ru:PersonSurname>
										<cat_ru:PersonName><xsl:value-of select="DocSig_PersonName2"/></cat_ru:PersonName>
										<xsl:if test="string-length(DocSig_PersonMiddleName)>0">
											<cat_ru:PersonMiddleName><xsl:value-of select="DocSig_PersonMiddleName"/></cat_ru:PersonMiddleName>
										</xsl:if>
										<xsl:if test="string-length(DocSig_PersonPost)>0">
											<cat_ru:PersonPost><xsl:value-of select="DocSig_PersonPost"/></cat_ru:PersonPost>
										</xsl:if>
									</catWH_ru:Captain>
								</xsl:if>
							</catWH_ru:Sea>
						</Transports>
					</xsl:for-each>
				</xsl:when>
				<xsl:when test="count(//CONOSAMENT)>0 and count(//ARRSEADECL)=0">
					<xsl:for-each select="//CONOSAMENT[1]/CONOSAMENT_ITEM">	
						<Transports>
							<catWH_ru:TransportModeCode>10</catWH_ru:TransportModeCode>
							<catWH_ru:TransportIdentifier><xsl:value-of select="VesselName"/></catWH_ru:TransportIdentifier>
							<catWH_ru:Sea>
								<xsl:if test="string-length(VesselNationalityCode)>0 or (string-length(VesselNationalityCodeNum)>0 and number(VesselNationalityCodeNum)>0)">
									<catWH_ru:CountryCode>
										<xsl:choose>
											<xsl:when test="string-length(VesselNationalityCode)>0">
												<xsl:value-of select="VesselNationalityCode"/>
											</xsl:when>
											<xsl:when test="string-length(VesselNationalityCodeNum)>0 and number(VesselNationalityCodeNum)>0">
												<xsl:variable select="VesselNationalityCodeNum" name="VNCode"/>
												<xsl:value-of select="$PathNsiWH//Country_ITEM[Code=$VNCode]/ABC2"/>
											</xsl:when>
										</xsl:choose>
									</catWH_ru:CountryCode>
								</xsl:if>
								<xsl:if test="string-length(DocSig_PersonName)>0 and string-length(DocSig_PersonName2)>0">
									<catWH_ru:Captain>
										<cat_ru:PersonSurname><xsl:value-of select="DocSig_PersonName"/></cat_ru:PersonSurname>
										<cat_ru:PersonName><xsl:value-of select="DocSig_PersonName2"/></cat_ru:PersonName>
										<xsl:if test="string-length(DocSig_PersonMiddleName)>0">
											<cat_ru:PersonMiddleName><xsl:value-of select="DocSig_PersonMiddleName"/></cat_ru:PersonMiddleName>
										</xsl:if>
										<xsl:if test="string-length(DocSig_PersonPost)>0">
											<cat_ru:PersonPost><xsl:value-of select="DocSig_PersonPost"/></cat_ru:PersonPost>
										</xsl:if>
									</catWH_ru:Captain>
								</xsl:if>
							</catWH_ru:Sea>
						</Transports>
					</xsl:for-each>	
				</xsl:when>
			</xsl:choose>
			<xsl:call-template name="FirmCarrier">
				<xsl:with-param name="Pref">Carrier_</xsl:with-param>
				<xsl:with-param name="PrefPerson">Carrier_Driver_</xsl:with-param>
			</xsl:call-template>
			<xsl:for-each select="//CONOSAMENT_ITEM">
				<xsl:variable name="num-conosament" select="RegNum"/>
				<GoodsShipment>
					<cat_ru:PrDocumentName>Коносамент</cat_ru:PrDocumentName>
					<cat_ru:PrDocumentNumber><xsl:value-of select="RegNum"/></cat_ru:PrDocumentNumber>
					<xsl:if test="string-length(RegDate)>0">
						<cat_ru:PrDocumentDate>
							<xsl:call-template name="TranslateDate">
								<xsl:with-param name="Dat" select="RegDate"/>
							</xsl:call-template>
						</cat_ru:PrDocumentDate>
					</xsl:if>	
					<catWH_ru:PresentedDocumentModeCode>02011</catWH_ru:PresentedDocumentModeCode>
					<catWH_ru:WhCommDoc>
						<xsl:call-template name="FirmConos"/>
					</catWH_ru:WhCommDoc>	
					<xsl:for-each select="CONOSAMENTGoods/CONOSAMENTGOODS_ITEM">
						<Goods>
							<catWH_ru:GoodsNumber><xsl:value-of select="position()"/></catWH_ru:GoodsNumber>
							<xsl:if test="string-length(GoodsNomenclatureCode)>0">
								<catWH_ru:GoodsTNVEDCode><xsl:value-of select="GoodsNomenclatureCode"/></catWH_ru:GoodsTNVEDCode>
							</xsl:if>
							<xsl:choose>
								<xsl:when test="string-length(Cost)>0 and not(contains(string(number(Cost)),'NaN'))">
									<catWH_ru:InvoiceCost><xsl:value-of select="format-number(round(Cost * 100) div 100,'0.##')"/></catWH_ru:InvoiceCost>
								</xsl:when>
								<xsl:when test="string-length(Price)>0 and string-length(GoodsQuantity)>0 and not(contains(string(number(Price)),'NaN')) and not(contains(string(number(GoodsQuantity)),'NaN'))">
									<catWH_ru:InvoiceCost><xsl:value-of select="format-number(round(Price * GoodsQuantity * 100) div 100,'0.##')"/></catWH_ru:InvoiceCost>
								</xsl:when>
							</xsl:choose>	
							<xsl:if test="string-length(../../CurrencyCode)>0">
								<catWH_ru:CurrencyCode><xsl:value-of select="../../CurrencyCode"/></catWH_ru:CurrencyCode>
							</xsl:if>
							<catWH_ru:GoodsDescriptionFull>
								<xsl:call-template name="GoodsDescrNew">
									<xsl:with-param name="DesGoods" select="normalize-space(GoodsDescription)"/>
									<xsl:with-param name="NodeName">catWH_ru:GoodsDescription</xsl:with-param>
									<xsl:with-param name="Namsp">urn:customs.ru:Information:WarehouseDocuments:WarehouseCommonAggregateTypesCust:5.24.0</xsl:with-param>
									<xsl:with-param name="LenDes">250</xsl:with-param>
								</xsl:call-template>
							</catWH_ru:GoodsDescriptionFull>
							<xsl:if test="string-length(PlacesQuantity)>0">
								<catWH_ru:CargoPlace>
									<catWH_ru:PlaceNumber><xsl:value-of select="PlacesQuantity"/></catWH_ru:PlaceNumber>
								</catWH_ru:CargoPlace>
							</xsl:if>
							<xsl:if test="string-length(GrossWeightQuantity)>0">
								<catWH_ru:BruttoVolQuant>
									<catWH_ru:GoodsQuantity><xsl:value-of select="format-number(round(GrossWeightQuantity * 1000) div 1000,'0.###')"/></catWH_ru:GoodsQuantity>
									<catWH_ru:MeasureUnitQualifierName>КГ</catWH_ru:MeasureUnitQualifierName>
									<catWH_ru:MeasureUnitQualifierCode>166</catWH_ru:MeasureUnitQualifierCode>
								</catWH_ru:BruttoVolQuant>
							</xsl:if>
							<xsl:if test="string-length(VolumeQuantity)>0">
								<catWH_ru:MeasureQuantity>
									<catWH_ru:GoodsQuantity><xsl:value-of select="format-number(round(VolumeQuantity * 1000) div 1000,'0.###')"/></catWH_ru:GoodsQuantity>
									<catWH_ru:MeasureUnitQualifierName>М3</catWH_ru:MeasureUnitQualifierName>
									<catWH_ru:MeasureUnitQualifierCode>113</catWH_ru:MeasureUnitQualifierCode>
								</catWH_ru:MeasureQuantity>
							</xsl:if>
						</Goods>
					</xsl:for-each>
					<xsl:variable name="NumSea" select="RegNum"/>
					<xsl:if test="count(//CONOSAMENTGoods/CONOSAMENTGOODS_ITEM[../../RegNum=$NumSea and string-length(ContainerNum)>0])>0">
						<xsl:variable name="ContainerConosament" select="//CONOSAMENTGoods/CONOSAMENTGOODS_ITEM/ContainerNum[generate-id(.)=generate-id(key('ContSeaWH',concat(../ContainerNum,$NumSea))) and string-length(../ContainerNum)>0]"/>
						<xsl:for-each select="$ContainerConosament">
							<xsl:variable name="n-container" select="."/>
							<Containers>
								<catWH_ru:ContainerNumber><xsl:value-of select="$n-container"/></catWH_ru:ContainerNumber>
								<xsl:variable name="GrossWeight" select="sum(//CONOSAMENTGoods/CONOSAMENTGOODS_ITEM[ContainerNum=$n-container and ../../RegNum=$NumSea and string-length(GrossWeightQuantity)>0]/GrossWeightQuantity)"/>
								<xsl:if test="$GrossWeight>0 and $GrossWeight!='NaN'">
									<catWH_ru:GrossWeightQuantity><xsl:value-of select="format-number(round($GrossWeight * 100000) div 100000,'0.######')"/></catWH_ru:GrossWeightQuantity>
								</xsl:if>	
							</Containers>
						</xsl:for-each>
					</xsl:if>
				</GoodsShipment>
			</xsl:for-each>
			<xsl:if test="count(//ARRSEADECLGoods/ARRSEADECLGOODS_ITEM[string-length(ConosamentNum)>0])>0">
				<xsl:apply-templates select="//ARRSEADECLGoods/ARRSEADECLGOODS_ITEM[generate-id(.)=generate-id(key('ConosamentArrDcl',ConosamentNum)) and string-length(ConosamentNum)>0]">
					<xsl:with-param name="ArrSeaD"  select="2"/>
				</xsl:apply-templates>
			</xsl:if>
		</WHDocInventory>
	</xsl:template>
	<xsl:template name="GoodsConosament" xmlns="urn:customs.ru:Information:WarehouseDocuments:WHDocInventory:5.24.0" xmlns:catWH_ru="urn:customs.ru:Information:WarehouseDocuments:WarehouseCommonAggregateTypesCust:5.24.0" xmlns:cat_ru="urn:customs.ru:CommonAggregateTypes:5.24.0">
		<xsl:param name="NumSea"/>
		<GoodsShipment>
			<cat_ru:PrDocumentName>Коносамент</cat_ru:PrDocumentName>
			<cat_ru:PrDocumentNumber><xsl:value-of select="$NumSea"/></cat_ru:PrDocumentNumber>
			<xsl:if test="string-length(RegDate)>0">
				<cat_ru:PrDocumentDate>
					<xsl:call-template name="TranslateDate">
						<xsl:with-param name="Dat" select="RegDate"/>
					</xsl:call-template>
				</cat_ru:PrDocumentDate>
			</xsl:if>	
			<catWH_ru:PresentedDocumentModeCode>02011</catWH_ru:PresentedDocumentModeCode>
			<catWH_ru:WhCommDoc>
				<xsl:call-template name="FirmConos"/>
			</catWH_ru:WhCommDoc>	
			<xsl:for-each select="CONOSAMENTGoods/CONOSAMENTGOODS_ITEM">
				<Goods>
					<catWH_ru:GoodsNumber><xsl:value-of select="position()"/></catWH_ru:GoodsNumber>
					<xsl:if test="string-length(GoodsNomenclatureCode)>0">
						<catWH_ru:GoodsTNVEDCode><xsl:value-of select="GoodsNomenclatureCode"/></catWH_ru:GoodsTNVEDCode>
					</xsl:if>
					<xsl:if test="string-length(Price)>0 and string-length(GoodsQuantity)>0">
						<catWH_ru:InvoiceCost><xsl:value-of select="format-number(round(Price * GoodsQuantity * 100) div 100,'0.##')"/></catWH_ru:InvoiceCost>
					</xsl:if>
					<xsl:if test="string-length(../../CurrencyCode)>0">
						<catWH_ru:CurrencyCode><xsl:value-of select="../../CurrencyCode"/></catWH_ru:CurrencyCode>
					</xsl:if>
					<catWH_ru:GoodsDescriptionFull>
						<xsl:call-template name="GoodsDescrNew">
							<xsl:with-param name="DesGoods" select="normalize-space(GoodsDescription)"/>
							<xsl:with-param name="NodeName">catWH_ru:GoodsDescription</xsl:with-param>
							<xsl:with-param name="Namsp">urn:customs.ru:Information:WarehouseDocuments:WarehouseCommonAggregateTypesCust:5.24.0</xsl:with-param>
							<xsl:with-param name="LenDes">250</xsl:with-param>
						</xsl:call-template>
					</catWH_ru:GoodsDescriptionFull>
					<xsl:if test="string-length(PlacesQuantity)>0">
						<catWH_ru:CargoPlace>
							<catWH_ru:PlaceNumber><xsl:value-of select="PlacesQuantity"/></catWH_ru:PlaceNumber>
						</catWH_ru:CargoPlace>
					</xsl:if>
					<xsl:if test="string-length(GrossWeightQuantity)>0">
						<catWH_ru:BruttoVolQuant>
							<catWH_ru:GoodsQuantity><xsl:value-of select="format-number(round(GrossWeightQuantity * 1000000) div 1000000,'0.######')"/></catWH_ru:GoodsQuantity>
							<catWH_ru:MeasureUnitQualifierName>КГ</catWH_ru:MeasureUnitQualifierName>
							<catWH_ru:MeasureUnitQualifierCode>166</catWH_ru:MeasureUnitQualifierCode>
						</catWH_ru:BruttoVolQuant>
					</xsl:if>
					<xsl:if test="string-length(VolumeQuantity)>0">
						<catWH_ru:MeasureQuantity>
							<catWH_ru:GoodsQuantity><xsl:value-of select="format-number(round(VolumeQuantity * 1000000) div 1000000,'0.######')"/></catWH_ru:GoodsQuantity>
							<catWH_ru:MeasureUnitQualifierName>М3</catWH_ru:MeasureUnitQualifierName>
							<catWH_ru:MeasureUnitQualifierCode>113</catWH_ru:MeasureUnitQualifierCode>
						</catWH_ru:MeasureQuantity>
					</xsl:if>
				</Goods>
			</xsl:for-each>
			<xsl:if test="count(//CONOSAMENTGoods/CONOSAMENTGOODS_ITEM[../../RegNum=$NumSea and string-length(ContainerNum)>0])>0">
				<xsl:variable name="ContainerConosament" select="//CONOSAMENTGoods/CONOSAMENTGOODS_ITEM/ContainerNum[generate-id(.)=generate-id(key('ContSeaWH',concat(../ContainerNum,$NumSea))) and string-length(../ContainerNum)>0]"/>
				<xsl:for-each select="$ContainerConosament">
					<xsl:variable name="n-container" select="."/>
					<Containers>
						<catWH_ru:ContainerNumber><xsl:value-of select="$n-container"/></catWH_ru:ContainerNumber>
						<xsl:variable name="GrossWeight" select="sum(//CONOSAMENTGoods/CONOSAMENTGOODS_ITEM[ContainerNum=$n-container and ../../RegNum=$NumSea and string-length(GrossWeightQuantity)>0]/GrossWeightQuantity)"/>
						<xsl:if test="$GrossWeight>0 and $GrossWeight!='NaN'">
							<catWH_ru:GrossWeightQuantity><xsl:value-of select="format-number(round($GrossWeight * 100000) div 100000,'0.######')"/></catWH_ru:GrossWeightQuantity>
						</xsl:if>	
					</Containers>
				</xsl:for-each>
			</xsl:if>
		</GoodsShipment>
	</xsl:template>

		<xsl:template name="FirmCarrier" xmlns="urn:customs.ru:Information:WarehouseDocuments:WHDocInventory:5.24.0" xmlns:catWH_ru="urn:customs.ru:Information:WarehouseDocuments:WarehouseCommonAggregateTypesCust:5.24.0" xmlns:cat_ru="urn:customs.ru:CommonAggregateTypes:5.24.0">
		<xsl:param name="Pref"/>
		<xsl:param name="PrefPerson"/>
		<xsl:variable name="NodeFirm">
			<xsl:choose>
				<xsl:when test="contains($Pref,'Carrier')">Carrier</xsl:when>
				<xsl:when test="contains($Pref,'Participant')">Participant</xsl:when>
			</xsl:choose>
		</xsl:variable>
		<xsl:variable name="NodePerson">
			<xsl:choose>
				<xsl:when test="contains($Pref,'Carrier')">catWH_ru:CarrierPerson</xsl:when>
				<xsl:when test="contains($Pref,'Participant')">Ambassador</xsl:when>
			</xsl:choose>
		</xsl:variable>
		<xsl:variable name="NodeSp">
			<xsl:choose>
				<xsl:when test="contains($Pref,'Carrier')">urn:customs.ru:Information:WarehouseDocuments:WarehouseCommonAggregateTypesCust:5.24.0</xsl:when>
				<xsl:when test="contains($Pref,'Participant')">urn:customs.ru:Information:WarehouseDocuments:WHDocInventory:5.24.0</xsl:when>
			</xsl:choose>
		</xsl:variable>
		<xsl:if test="string-length(*[name()=concat($Pref,'Name')])>0 or string-length(*[name()=concat($Pref,'CountryCode')])>0">
			<xsl:element name="{$NodeFirm}" namespace="urn:customs.ru:Information:WarehouseDocuments:WHDocInventory:5.24.0">
				<xsl:call-template name="OrgNode">
					<xsl:with-param name="Pref" select="$Pref"/>
					<xsl:with-param name="PostalAddress">
						<xsl:choose>
							<xsl:when test="contains($Pref,'Carrier')">4</xsl:when>
							<xsl:when test="contains($Pref,'Participant')">3</xsl:when>
						</xsl:choose>
					</xsl:with-param>
					<xsl:with-param name="NameSp">urn:customs.ru:CommonAggregateTypes:5.24.0</xsl:with-param>
					<xsl:with-param name="NamspNode">urn:customs.ru:Information:WarehouseDocuments:WHDocInventory:5.24.0</xsl:with-param>
					<xsl:with-param name="NamspNodeAdr">urn:customs.ru:Information:WarehouseDocuments:WarehouseCommonAggregateTypesCust:5.24.0</xsl:with-param>
					<xsl:with-param name="VerAlb">5.16.0</xsl:with-param>
				</xsl:call-template>
				<xsl:if test="string-length(*[name()=concat($PrefPerson,'PersonName')])>0 or string-length(*[name()=concat($PrefPerson,'PersonSurname')])>0 or string-length(*[name()=concat($PrefPerson,'PersonPost')])>0">
					<xsl:element name="{$NodePerson}" namespace="{$NodeSp}">
						<xsl:if test="string-length(*[name()=concat($PrefPerson,'PersonSurname')])>0">
							<cat_ru:PersonSurname><xsl:value-of select="*[name()=concat($PrefPerson,'PersonSurname')]"/></cat_ru:PersonSurname>
						</xsl:if>
						<xsl:if test="string-length(*[name()=concat($PrefPerson,'PersonName')])>0">
							<cat_ru:PersonName><xsl:value-of select="*[name()=concat($PrefPerson,'PersonName')]"/></cat_ru:PersonName>
						</xsl:if>
						<xsl:if test="string-length(*[name()=concat($PrefPerson,'PersonMiddleName')])>0">
							<cat_ru:PersonMiddleName><xsl:value-of select="*[name()=concat($PrefPerson,'PersonMiddleName')]"/></cat_ru:PersonMiddleName>
						</xsl:if>
						<xsl:if test="string-length(*[name()=concat($PrefPerson,'PersonPost')])>0">
							<cat_ru:PersonPost><xsl:value-of select="*[name()=concat($PrefPerson,'PersonPost')]"/></cat_ru:PersonPost>
						</xsl:if>
					</xsl:element>
				</xsl:if>		
			</xsl:element>
		</xsl:if>	
	</xsl:template>		
</xsl:stylesheet>
