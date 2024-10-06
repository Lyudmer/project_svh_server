<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
<!--	<xsl:import href="../COMMON/function_for_server.xsl"/>-->
	<xsl:variable name="seacontnsi" select="document('../NSI/TranspNSIXml.xml')"/>
	
	<xsl:key use="concat(../ContainerNum,../../../RegNum)" name="ContSeaWH" match="//CONOSAMENTGoods/CONOSAMENTGOODS_ITEM[string-length(ContainerNum)>0]/ContainerNum"/>
	<xsl:key use="concat(../ContainerNum,../../../RegNum,../../../PI_RegID)" name="ContSeaWHUIN" match="//CONOSAMENTGoods/CONOSAMENTGOODS_ITEM[string-length(ContainerNum)>0]/ContainerNum"/>
	<xsl:key use="concat(../ContainerID,../../../ConosamentNum,../../../ConosamentID)" name="ArrDclContSeaWH" match="//ARRSEADECLGOODS_ITEM/Container/CONTAINER_ITEM[string-length(ContainerID)>0]/ContainerID"/>
	<xsl:key use="concat(./DangerIMO,../../ConosamentNum)" name="DangerIMO" match="//Danger/DANGER_ITEM"/>
	<xsl:key use="concat(./UNNO,../../ConosamentNum)" name="UNNO" match="//Danger/DANGER_ITEM"/>
	<xsl:key use="./ConosamentNum" name="ConosamentArrDcl" match="//ARRSEADECLGOODS_ITEM[string-length(ConosamentNum)>0]"/>
	<xsl:key use="concat(./ConosamentNum,./ConosamentID)" name="ArrdclConosamentUIN" match="//ARRSEADECLGOODS_ITEM[string-length(ConosamentNum)>0 and string-length(ConosamentID)>0]"/>
	<xsl:template match="//Danger/DANGER_ITEM" xmlns="urn:customs.ru:Information:TransportDocuments:Sea:BillofLading:5.24.0" xmlns:catTrans_ru="urn:customs.ru:Information:TransportDocuments:TransportCommonAgregateTypesCust:5.24.0">
		<xsl:param name="Nums"/>
		<xsl:param name="Level"/>
		<xsl:if  test="../../ConosamentNum=$Nums">
			<xsl:choose>
				<xsl:when test="$Level=0">
					<catTrans_ru:HazardousCargoCode><xsl:value-of select="DangerIMO"/></catTrans_ru:HazardousCargoCode>
				</xsl:when>
				<xsl:when test="$Level=1">
					<UNnumber><xsl:value-of select="UNNO"/></UNnumber>			
				</xsl:when>
			</xsl:choose>
		</xsl:if>
	</xsl:template>
	<xsl:template name="ArrSeaGoodsShipment">
		<xsl:param name="ConosNum"/>
		<GoodsShipment xmlns="urn:customs.ru:Information:WarehouseDocuments:WHDocInventory:5.24.0" xmlns:catWH_ru="urn:customs.ru:Information:WarehouseDocuments:WarehouseCommonAggregateTypesCust:5.24.0" xmlns:cat_ru="urn:customs.ru:CommonAggregateTypes:5.24.0" >
			<cat_ru:PrDocumentName>Коносамент</cat_ru:PrDocumentName>
			<cat_ru:PrDocumentNumber><xsl:value-of select="$ConosNum"/></cat_ru:PrDocumentNumber>
			<xsl:if test="string-length(ConosamentDate)>0">
				<cat_ru:PrDocumentDate>
					<xsl:call-template name="TranslateDate">
						<xsl:with-param name="Dat" select="ConosamentDate"/>
					</xsl:call-template>
				</cat_ru:PrDocumentDate>
			</xsl:if>
			<catWH_ru:PresentedDocumentModeCode>02011</catWH_ru:PresentedDocumentModeCode>
			<catWH_ru:WhCommDoc>
				<xsl:if test="string-length(Consignor_Name)>0">
					<catWH_ru:Consignor>
						<xsl:if test="string-length(Consignor_CountryCode)>0">
							<catWH_ru:CountryCode><xsl:value-of select="Consignor_CountryCode"/></catWH_ru:CountryCode>
						</xsl:if>
						<catWH_ru:OrganizationName>
							<xsl:value-of select="substring(normalize-space(Consignor_Name),1,150)"/>
						</catWH_ru:OrganizationName>
						<xsl:call-template name="Address">
							<xsl:with-param name="Pref">Consignor_</xsl:with-param>
							<xsl:with-param name="NodeName">catWH_ru:Address</xsl:with-param>
							<xsl:with-param name="Namsp">urn:customs.ru:CommonAggregateTypes:5.24.0</xsl:with-param>
							<xsl:with-param name="NamspNode">urn:customs.ru:Information:WarehouseDocuments:WarehouseCommonAggregateTypesCust:5.24.0</xsl:with-param>
						</xsl:call-template>
					</catWH_ru:Consignor>
				</xsl:if>
				<catWH_ru:Consignee>
					<xsl:call-template name="OrgNode">
						<xsl:with-param name="Pref">Consignee_</xsl:with-param>
						<xsl:with-param name="PostalAddress">4</xsl:with-param>
						<xsl:with-param name="NameSp">urn:customs.ru:CommonAggregateTypes:5.24.0</xsl:with-param>
						<xsl:with-param name="NamspNode">urn:customs.ru:Information:WarehouseDocuments:WarehouseCommonAggregateTypesCust:5.24.0</xsl:with-param>
						<xsl:with-param name="NamspNodeAdr">urn:customs.ru:Information:WarehouseDocuments:WarehouseCommonAggregateTypesCust:5.24.0</xsl:with-param>
					</xsl:call-template>
				</catWH_ru:Consignee>
			</catWH_ru:WhCommDoc>	
			<xsl:for-each select="//ARRSEADECLGOODS_ITEM[ConosamentNum=$ConosNum]">
				<Goods>
					<catWH_ru:GoodsNumber><xsl:value-of select="position()"/></catWH_ru:GoodsNumber>
					<xsl:if test="string-length(GoodsTNVEDCode)>0">
						<catWH_ru:GoodsTNVEDCode><xsl:value-of select="GoodsTNVEDCode"/></catWH_ru:GoodsTNVEDCode>
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
							<catWH_ru:GoodsQuantity><xsl:value-of select="format-number(round(GrossWeightQuantity * 100000) div 100000,'0.######')"/></catWH_ru:GoodsQuantity>
							<catWH_ru:MeasureUnitQualifierName>КГ</catWH_ru:MeasureUnitQualifierName>
							<catWH_ru:MeasureUnitQualifierCode>166</catWH_ru:MeasureUnitQualifierCode>
						</catWH_ru:BruttoVolQuant>
					</xsl:if>
					<xsl:variable name="SumVolum" select="sum(Container/CONTAINER_ITEM[string-length(VolumeQuantity)>0]/VolumeQuantity)"/>
					<xsl:choose>
						<xsl:when test="string-length(SupplementaryGoodsQuantity)>0 and sum(Container/CONTAINER_ITEM[string-length(VolumeQuantity)>0]/VolumeQuantity)!=number(SupplementaryGoodsQuantity) and string-length(SupplementaryMeasureUnitCode)>0">
							<catWH_ru:MeasureQuantity>
								<catWH_ru:GoodsQuantity><xsl:value-of select="format-number(round(SupplementaryGoodsQuantity * 100000) div 100000,'0.######')"/></catWH_ru:GoodsQuantity>
								<xsl:variable name="CodeUn" select="SupplementaryMeasureUnitCode"/>
								<catWH_ru:MeasureUnitQualifierName><xsl:value-of select="$seacontnsi//UNIT_ITEM[CODE=$CodeUn]/ABBR"/></catWH_ru:MeasureUnitQualifierName>
								<catWH_ru:MeasureUnitQualifierCode><xsl:value-of select="$CodeUn"/></catWH_ru:MeasureUnitQualifierCode>
							</catWH_ru:MeasureQuantity>
						</xsl:when>
						<xsl:when test="$SumVolum>0">
							<catWH_ru:MeasureQuantity>
								<catWH_ru:GoodsQuantity><xsl:value-of select="format-number(round($SumVolum * 100000) div 100000,'0.######')"/></catWH_ru:GoodsQuantity>
								<catWH_ru:MeasureUnitQualifierName>М3</catWH_ru:MeasureUnitQualifierName>
								<catWH_ru:MeasureUnitQualifierCode>113</catWH_ru:MeasureUnitQualifierCode>
							</catWH_ru:MeasureQuantity>
						</xsl:when>
					</xsl:choose>
				</Goods>
			</xsl:for-each>
			<xsl:for-each select="//Container/CONTAINER_ITEM[../../ConosamentNum=$ConosNum and string-length(ContainerID)>0]">
				<xsl:variable name="ContNum" select="ContainerID"/>
				<Containers>
					<catWH_ru:ContainerNumber><xsl:value-of select="ContainerID"/></catWH_ru:ContainerNumber>
					<xsl:variable name="WhC1" select="sum(//Container/CONTAINER_ITEM[../../ConosamentNum=$ConosNum and ContainerID=$ContNum]/Weight)"/>
						<xsl:if test="$WhC1>0 and not(contains($WhC1,'NaN'))">
							<catWH_ru:GrossWeightQuantity><xsl:value-of select="format-number(round($WhC1 * 100000) div 100000,'0.######')"/></catWH_ru:GrossWeightQuantity>
						</xsl:if>	
				</Containers>
			</xsl:for-each>
		</GoodsShipment>
	</xsl:template>				
	<xsl:template match="//ARRSEADECLGOODS_ITEM">
		<xsl:param name="ArrSeaD"/>
		<xsl:variable name="ConosNum" select="ConosamentNum"/>	
		<xsl:choose>
			<xsl:when test="$ArrSeaD=1">
				<xsl:if test="count(//CONOSAMENT_ITEM[RegNum=$ConosNum])=0">
					<ContainerDoc xmlns="urn:customs.ru:Information:ExchangeDocuments:ED_Container:5.24.0">
						<DocBody>
							<BillofLading xmlns="urn:customs.ru:Information:TransportDocuments:Sea:BillofLading:5.24.0"  xmlns:cat_ru="urn:customs.ru:CommonAggregateTypes:5.24.0" xmlns:catTrans_ru="urn:customs.ru:Information:TransportDocuments:TransportCommonAgregateTypesCust:5.24.0"  xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" DocumentModeID="1003202E">
								<cat_ru:DocumentID>00000000-0000-0000-0000-000000000000</cat_ru:DocumentID>
								<xsl:choose>
									<xsl:when test="string-length(../../LanguageCode)>0">
										<LanguageCode><xsl:value-of select="../../LanguageCode"/></LanguageCode>
									</xsl:when>
									<xsl:otherwise>
										<LanguageCode>EN</LanguageCode>
									</xsl:otherwise>
								</xsl:choose>
								<xsl:if test="string-length(../../Clause)>0">
									<Clause><xsl:value-of select="../../Clause"/></Clause>
								</xsl:if>
								<RegistrationDocument>
									<xsl:if test="string-length(ConosamentName)>0">
										<cat_ru:PrDocumentName><xsl:value-of select="ConosamentName"/></cat_ru:PrDocumentName>
									</xsl:if>
									<xsl:if test="string-length($ConosNum)>0">
										<cat_ru:PrDocumentNumber><xsl:value-of select="$ConosNum"/></cat_ru:PrDocumentNumber>
									</xsl:if>
									<xsl:if test="string-length(ConosamentDate)>0">
										<cat_ru:PrDocumentDate>
											<xsl:call-template name="TranslateDate">
												<xsl:with-param name="Dat"  select="ConosamentDate"/>
											</xsl:call-template>									
										</cat_ru:PrDocumentDate>
									</xsl:if>
								</RegistrationDocument>
								<Vessel>
									<catTrans_ru:Name><xsl:value-of select="../../VesselName"/></catTrans_ru:Name>
									<xsl:if test="string-length(../../VesselShipmaster)>0">
										<catTrans_ru:Shipmaster><xsl:value-of select="../../VesselShipmaster"/></catTrans_ru:Shipmaster>
									</xsl:if>
									<xsl:if test="string-length(../../VesselNationalityCode)>0">
										<xsl:variable name="VesCr" select="contains(../../VesselNationalityCode,'NaN')"/>
										<xsl:choose>
											<xsl:when test="$VesCr">
												<xsl:variable name="VesselNationalityCode" select="../../VesselNationalityCode"/>
												<catTrans_ru:NationalityCode><xsl:value-of select="$seacontnsi//Country_ITEM[ABC2=$VesselNationalityCode]/Code"/></catTrans_ru:NationalityCode>
											</xsl:when>
											<xsl:otherwise>
												<catTrans_ru:NationalityCode><xsl:value-of select="../../VesselNationalityCode"/></catTrans_ru:NationalityCode>
											</xsl:otherwise>
										</xsl:choose>	
									</xsl:if>							
								</Vessel>
								<Loading>
									<catTrans_ru:Name><xsl:value-of select="substring(normalize-space(DepartureGoodsPort),1,50)"/></catTrans_ru:Name>
								</Loading>
								<Unloading>
									<catTrans_ru:Name><xsl:value-of select="substring(normalize-space(DebarkationPort),1,50)"/></catTrans_ru:Name>
								</Unloading>
								<Carrier>
									<xsl:call-template name="FirmNodeConstr">
										<xsl:with-param name="Pref">Carrier_</xsl:with-param>
										<xsl:with-param name="NameSp">urn:customs.ru:CommonAggregateTypes:5.24.0</xsl:with-param>
										<xsl:with-param name="NamspNode">urn:customs.ru:CommonAggregateTypes:5.24.0</xsl:with-param>
										<xsl:with-param name="NodeNameAdr">cat_ru:Address</xsl:with-param>
										<xsl:with-param name="NodeNameContact">cat_ru:Contact</xsl:with-param>
									</xsl:call-template>			
								</Carrier>
								<xsl:if test="string-length(Consignee_Name)>0 or string-length(Consignee_INN)>0 or string-length(Consignee_PostalCode)>0 or string-length(Consignee_StreetHouse)>0 or string-length(Consignee_CountryCode)>0 or string-length(Consignee_CountryName)>0 or string-length(Consignee_City)>0">
									<Consignee>
										<xsl:call-template name="FirmNodeConstr">
											<xsl:with-param name="Pref">Consignee_</xsl:with-param>
											<xsl:with-param name="NameSp">urn:customs.ru:CommonAggregateTypes:5.24.0</xsl:with-param>
											<xsl:with-param name="NamspNode">urn:customs.ru:CommonAggregateTypes:5.24.0</xsl:with-param>
											<xsl:with-param name="NodeNameAdr">cat_ru:Address</xsl:with-param>
											<xsl:with-param name="NodeNameContact">cat_ru:Contact</xsl:with-param>
										</xsl:call-template>						
									</Consignee>
								</xsl:if>
								<Consignor>
									<xsl:call-template name="FirmNodeConstr">
										<xsl:with-param name="Pref">Consignor_</xsl:with-param>
										<xsl:with-param name="NameSp">urn:customs.ru:CommonAggregateTypes:5.24.0</xsl:with-param>
										<xsl:with-param name="NamspNode">urn:customs.ru:CommonAggregateTypes:5.24.0</xsl:with-param>
										<xsl:with-param name="NodeNameAdr">cat_ru:Address</xsl:with-param>
										<xsl:with-param name="NodeNameContact">cat_ru:Contact</xsl:with-param>
									</xsl:call-template>										
								</Consignor>
								<xsl:for-each select="//ARRSEADECLGOODS_ITEM[ConosamentNum=$ConosNum]">	
									<Goods>
										<xsl:if test="string-length(GoodsMarking)>0">
											<cat_ru:GoodsMarking><xsl:value-of select="substring(normalize-space(GoodsMarking),1,30)"/></cat_ru:GoodsMarking>
										</xsl:if>
										<xsl:call-template name="GoodsDescrNew">
											<xsl:with-param name="DesGoods" select="normalize-space(GoodsDescription)"/>
											<xsl:with-param name="NodeName">cat_ru:GoodsDescription</xsl:with-param>
											<xsl:with-param name="Namsp">urn:customs.ru:CommonAggregateTypes:5.24.0</xsl:with-param>
											<xsl:with-param name="NameMes" select="true"/> 
											<xsl:with-param name="LenDes">250</xsl:with-param>
										</xsl:call-template>
										<catTrans_ru:GoodsNumeric><xsl:value-of select="position()"/></catTrans_ru:GoodsNumeric>
										<xsl:if test="string-length(GoodsTNVEDCode)>0">
											<catTrans_ru:GoodsNomenclatureCode><xsl:value-of select="GoodsTNVEDCode"/></catTrans_ru:GoodsNomenclatureCode>
										</xsl:if>
										<xsl:choose>
											<xsl:when test="count(Danger/DANGER_ITEM[string-length(DangerIMO)>0])>0">
												<xsl:apply-templates select="Danger/DANGER_ITEM[generate-id(.)=generate-id(key('DangerIMO',concat(./DangerIMO,$ConosNum)))]">
													<xsl:with-param name="Level">0</xsl:with-param>
													<xsl:with-param name="Nums" select="$ConosNum"/>
												</xsl:apply-templates>
											</xsl:when>	
											<xsl:when test="string-length(DangerIMO)>0">
												<catTrans_ru:HazardousCargoCode><xsl:value-of select="DangerIMO"/></catTrans_ru:HazardousCargoCode>
											</xsl:when>
										</xsl:choose>
										<xsl:if test="string-length(PlacesQuantity)>0 and not(contains(PlacesQuantity,'NaN'))">
											<PlacesQuantity><xsl:value-of select="PlacesQuantity"/></PlacesQuantity>
										</xsl:if>
										<GrossWeightQuantity>
											<xsl:choose>
												<xsl:when test="string-length(GrossWeightQuantity)>0 and not(contains(GrossWeightQuantity,'NaN'))">
													<xsl:value-of select="format-number(round(GrossWeightQuantity * 1000) div 1000,'0.####')"/>
												</xsl:when>
												<xsl:otherwise>0</xsl:otherwise>
											</xsl:choose>
										</GrossWeightQuantity>
										<xsl:if test="string-length(TotalWeightWithCont)>0  and not(contains(TotalWeightWithCont,'NaN'))">
											<WeightWithCont><xsl:value-of select="TotalWeightWithCont"/></WeightWithCont>
										</xsl:if>	
										<xsl:if test="string-length(PlacesDescription)>0">
											<PackingDescription><xsl:value-of select="PlacesDescription"/></PackingDescription>
										</xsl:if>	
										<xsl:for-each select="Container/CONTAINER_ITEM[string-length(ContainerID)>0]">
											<Container>
												<ContainerNum><xsl:value-of select="ContainerID"/></ContainerNum>
												<xsl:if test="string-length(SealID)>0">
													<xsl:call-template name="SealsNodeForConosament">
														<xsl:with-param name="NameSl">SealID</xsl:with-param>
														<xsl:with-param name="NameSp">urn:customs.ru:Information:TransportDocuments:Sea:BillofLading:5.24.0</xsl:with-param>
														<xsl:with-param name="NameNode">Seal</xsl:with-param>
														<xsl:with-param name="LenDes">50</xsl:with-param>
													</xsl:call-template>
												</xsl:if>
											</Container>	
										</xsl:for-each>
											<xsl:choose>
												<xsl:when test="count(Danger/DANGER_ITEM[string-length(UNNO)>0])>0">
													<xsl:apply-templates select="Danger/DANGER_ITEM[generate-id(.)=generate-id(key('UNNO',concat(./UNNO,$ConosNum)))]">
														<xsl:with-param name="Nums" select="$ConosNum"/>
														<xsl:with-param name="Level">1</xsl:with-param>
													</xsl:apply-templates>
												</xsl:when>	
												<xsl:when test="string-length(normalize-space(UNNO))>0">
													<UNnumber><xsl:value-of select="UNNO"/></UNnumber>
												</xsl:when>
											</xsl:choose>
									</Goods>
								</xsl:for-each>
								<DocumentSignature>
									<xsl:choose>
										<xsl:when test="string-length(../../DocSig_PersonName)>0 or string-length(../../DocSig_PersonName2)>0">
											<xsl:variable name="PersonName">
												<xsl:value-of select="concat(../../DocSig_PersonName,' ',../../DocSig_PersonName2)"/>
												<xsl:if test="string-length(../../DocSig_PersonMiddleName)>0">
													<xsl:value-of select="../../DocSig_PersonMiddleName"/>
												</xsl:if>
											</xsl:variable>
											<PersonName><xsl:value-of select="normalize-space($PersonName)"/></PersonName>	
											<xsl:if test="string-length(../../DocSig_PersonPost)>0">
												<PersonPost><xsl:value-of select="../../DocSig_PersonPost"/></PersonPost>
											</xsl:if>
											<xsl:if test="string-length(../../DocSig_IssueDate)>0">								
												<IssueDate>
													<xsl:call-template name="TranslateDate">
														<xsl:with-param name="Dat"  select="../../DocSig_IssueDate"/>
													</xsl:call-template>								
												</IssueDate>
											</xsl:if>	
										</xsl:when>
										<xsl:when test="count(//GENERALDECL/GENERALDECL_ITEM[string-length(DocSig_PersonName)>0 or string-length(DocSig_PersonName2)>0])">
											<xsl:for-each select="//GENERALDECL/GENERALDECL_ITEM[string-length(DocSig_PersonName)>0 or string-length(DocSig_PersonName2)>0]">
												<xsl:variable name="PersonNameGd">
													<xsl:value-of select="concat(DocSig_PersonName,' ',DocSig_PersonName2)"/>
													<xsl:if test="string-length(DocSig_PersonMiddleName)>0">
														<xsl:value-of select="DocSig_PersonMiddleName"/>
													</xsl:if>
												</xsl:variable>
												<PersonName><xsl:value-of select="normalize-space($PersonNameGd)"/></PersonName>	
												<xsl:if test="string-length(DocSig_PersonPost)>0">
													<PersonPost><xsl:value-of select="DocSig_PersonPost"/></PersonPost>
												</xsl:if>
												<xsl:if test="string-length(DocSig_IssueDate)>0">								
													<IssueDate>
														<xsl:call-template name="TranslateDate">
															<xsl:with-param name="Dat"  select="DocSig_IssueDate"/>
														</xsl:call-template>								
													</IssueDate>
												</xsl:if>	
											</xsl:for-each>
										</xsl:when>
									</xsl:choose>
								</DocumentSignature>
								<xsl:for-each select="//ARRSEADECLGOODS_ITEM[ConosamentNum=$ConosNum]/COMMISSIONSHIPMENTDOC/COMMISSIONSHIPMENTDOC_ITEM[string-length(normalize-space(concat(PrDocumentName,PrDocumentNumber,PrDocumentDate)))>0]">
									<CommissionShipment>
										<xsl:if test="string-length(PrDocumentName)>0">
											<cat_ru:PrDocumentName><xsl:value-of select="PrDocumentName"/></cat_ru:PrDocumentName>
										</xsl:if>
										<xsl:if test="string-length(PrDocumentNumber)>0">
											<cat_ru:PrDocumentNumber><xsl:value-of select="PrDocumentNumber"/></cat_ru:PrDocumentNumber>
										</xsl:if>
										<xsl:if test="string-length(PrDocumentDate)>0">
											<cat_ru:PrDocumentDate>
												<xsl:call-template name="TranslateDate">
													<xsl:with-param name="Dat" select="PrDocumentDate"/>
												</xsl:call-template>
											</cat_ru:PrDocumentDate>
										</xsl:if>
									</CommissionShipment>
								</xsl:for-each>
								<xsl:if  test="string-length(DestinationOfficeIdentifier)>0">
									<DestinationOfficeIdentifier><xsl:value-of select="DestinationOfficeIdentifier"/></DestinationOfficeIdentifier>
								</xsl:if>	
							</BillofLading>
						</DocBody>
					</ContainerDoc>
				</xsl:if>	
			</xsl:when>
			<xsl:when test="$ArrSeaD=2">
				<xsl:if test="count(//CONOSAMENT_ITEM[RegNum=$ConosNum])=0">
					<xsl:call-template name="ArrSeaGoodsShipment">
						<xsl:with-param name="ConosNum" select="$ConosNum"/>
					</xsl:call-template>
				</xsl:if>
			</xsl:when>
		</xsl:choose>
	</xsl:template>
	
	
	<xsl:template name="FirmConos" xmlns="urn:customs.ru:Information:WarehouseDocuments:WHDocInventory:5.24.0" xmlns:catWH_ru="urn:customs.ru:Information:WarehouseDocuments:WarehouseCommonAggregateTypesCust:5.24.0" xmlns:cat_ru="urn:customs.ru:CommonAggregateTypes:5.24.0">
		<xsl:if test="string-length(Consignor_Name)>0">
			<catWH_ru:Consignor>
				<xsl:if test="string-length(Consignor_CountryCode)>0">
					<catWH_ru:CountryCode><xsl:value-of select="Consignor_CountryCode"/></catWH_ru:CountryCode>
				</xsl:if>
				<catWH_ru:OrganizationName>
					<xsl:value-of select="substring(normalize-space(Consignor_Name),1,150)"/>
				</catWH_ru:OrganizationName>
				<xsl:call-template name="Address">
					<xsl:with-param name="Pref">Consignor_</xsl:with-param>
					<xsl:with-param name="NodeName">catWH_ru:Address</xsl:with-param>
					<xsl:with-param name="Namsp">urn:customs.ru:CommonAggregateTypes:5.24.0</xsl:with-param>
					<xsl:with-param name="NamspNode">urn:customs.ru:Information:WarehouseDocuments:WarehouseCommonAggregateTypesCust:5.24.0</xsl:with-param>
				</xsl:call-template>
			</catWH_ru:Consignor>
		</xsl:if>
		<xsl:choose>
			<xsl:when test="string-length(Consignee_Name)>0">
				<catWH_ru:Consignee>
					<xsl:call-template name="OrgNode">
						<xsl:with-param name="Pref">Consignee_</xsl:with-param>
						<xsl:with-param name="PostalAddress">4</xsl:with-param>
						<xsl:with-param name="NameSp">urn:customs.ru:CommonAggregateTypes:5.24.0</xsl:with-param>
						<xsl:with-param name="NamspNode">urn:customs.ru:Information:WarehouseDocuments:WarehouseCommonAggregateTypesCust:5.24.0</xsl:with-param>
						<xsl:with-param name="NamspNodeAdr">urn:customs.ru:Information:WarehouseDocuments:WarehouseCommonAggregateTypesCust:5.24.0</xsl:with-param>
					</xsl:call-template>
				</catWH_ru:Consignee>
			</xsl:when>
			<xsl:otherwise>
				<catWH_ru:Consignee>
					<catWH_ru:Address/>
				</catWH_ru:Consignee>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
		
</xsl:stylesheet>
