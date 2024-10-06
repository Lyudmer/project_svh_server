<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
	<xsl:import href="../COMMON/function_for_server.xsl"/>
	<xsl:template match="/Package">
		<xsl:call-template name="CONOSAMENT"/>
	</xsl:template>
	<xsl:variable name="NsiCon" select="document('../NSI/TranspNSIXml.xml')"/>
	<xsl:template name="ConosamentGoods">
		<xsl:param name="numdatdoc"/>
		<xsl:variable name="groupgoods" select="concat($numdatdoc,GoodsNomenclatureCode,GoodsDescription)"/>
		<xsl:variable name="sumVol" select="sum(//*[name()='CONOSAMENTGOODS_ITEM' or name()='CONOSAMENTGoods_ITEM'][concat(../../RegNum,substring(../../RegDate,1,10),./GoodsNomenclatureCode,./GoodsDescription)=$groupgoods][string-length(VolumeQuantity)>0]/VolumeQuantity)"/>
		<xsl:variable name="sumPlace" select="sum(//*[name()='CONOSAMENTGOODS_ITEM' or name()='CONOSAMENTGoods_ITEM'][concat(../../RegNum,substring(../../RegDate,1,10),./GoodsNomenclatureCode,./GoodsDescription)=$groupgoods][string-length(PlacesQuantity)>0]/PlacesQuantity)"/>
    	<xsl:variable name="sumGrWh" select="sum(//*[name()='CONOSAMENTGOODS_ITEM' or name()='CONOSAMENTGoods_ITEM'][concat(../../RegNum,substring(../../RegDate,1,10),./GoodsNomenclatureCode,./GoodsDescription)=$groupgoods][string-length(GrossWeightQuantity)>0]/GrossWeightQuantity)"/>
		<Goods xmlns="urn:customs.ru:Information:TransportDocuments:Sea:BillofLading:5.24.0"  xmlns:cat_ru="urn:customs.ru:CommonAggregateTypes:5.24.0" xmlns:catTrans_ru="urn:customs.ru:Information:TransportDocuments:TransportCommonAgregateTypesCust:5.24.0">
			<xsl:if test="string-length(GoodsMarking)>0">
				<cat_ru:GoodsMarking><xsl:value-of select="substring(normalize-space(GoodsMarking),1,30)"/></cat_ru:GoodsMarking>
			</xsl:if>
			<xsl:call-template name="GoodsDescrNew">
				<xsl:with-param name="DesGoods" select="substring(normalize-space(GoodsDescription),1,2000)"/>
				<xsl:with-param name="NodeName">cat_ru:GoodsDescription</xsl:with-param>
				<xsl:with-param name="Namsp">urn:customs.ru:CommonAggregateTypes:5.24.0</xsl:with-param>
				<xsl:with-param name="NameMes" select="true"/> 
				<xsl:with-param name="LenDes">250</xsl:with-param>
			</xsl:call-template>
			<catTrans_ru:GoodsNumeric><xsl:value-of select="position()"/></catTrans_ru:GoodsNumeric>
			<xsl:if test="string-length(GoodsNomenclatureCode)>0">
				<catTrans_ru:GoodsNomenclatureCode><xsl:value-of select="GoodsNomenclatureCode"/></catTrans_ru:GoodsNomenclatureCode>
			</xsl:if>
			<xsl:choose>
				<xsl:when test="count(Danger/DANGER_ITEM[string-length(DangerIMO)>0])>0">
					<xsl:for-each select="Danger/DANGER_ITEM[string-length(DangerIMO)>0]">
						<catTrans_ru:HazardousCargoCode><xsl:value-of select="substring(DangerIMO,1,3)"/></catTrans_ru:HazardousCargoCode>
					</xsl:for-each>	
				</xsl:when>
				<xsl:when test="string-length(DangerIMO)>0">
					<catTrans_ru:HazardousCargoCode><xsl:value-of select="substring(DangerIMO,1,3)"/></catTrans_ru:HazardousCargoCode>
				</xsl:when>
			</xsl:choose>
			<xsl:choose>
				<xsl:when test="string-length($numdatdoc)>0 and not(contains($sumVol,'NaN')) and number($sumVol)>0">
					<catTrans_ru:VolumeQuantity><xsl:value-of select="format-number(round($sumVol * 1000000) div 1000000,'0.######')"/></catTrans_ru:VolumeQuantity>
				</xsl:when>
				<xsl:otherwise>
					<xsl:if test="string-length(VolumeQuantity)>0">
						<catTrans_ru:VolumeQuantity><xsl:value-of select="VolumeQuantity"/></catTrans_ru:VolumeQuantity>
					</xsl:if>
				</xsl:otherwise>
			</xsl:choose>
			<xsl:choose>
				<xsl:when test="string-length($numdatdoc)>0 and not(contains($sumPlace,'NaN')) and number($sumPlace)>0">
					<PlacesQuantity><xsl:value-of select="format-number(round($sumPlace * 1000000) div 1000000,'0.######')"/></PlacesQuantity>
				</xsl:when>
				<xsl:when  test="string-length(PlacesQuantity)>0">
						<PlacesQuantity><xsl:value-of select="PlacesQuantity"/></PlacesQuantity>
				</xsl:when>
			</xsl:choose>
			<GrossWeightQuantity>
				<xsl:choose>
					<xsl:when test="string-length($numdatdoc)>0 and not(contains($sumGrWh,'NaN')) and number($sumGrWh)>0">
						<xsl:value-of select="format-number(round($sumGrWh * 1000000) div 1000000,'0.######')"/>
					</xsl:when>
					<xsl:when test="string-length(GrossWeightQuantity)>0  and not(contains(GrossWeightQuantity,'NaN'))">
						<xsl:value-of select="format-number(round(GrossWeightQuantity * 1000) div 1000,'0.####')"/>
					</xsl:when>
					<xsl:otherwise>0</xsl:otherwise>
				</xsl:choose>
			</GrossWeightQuantity>
			<xsl:if test="string-length(WeightWithCont)>0 and not(contains(WeightWithCont,'NaN'))">
				<WeightWithCont><xsl:value-of select="WeightWithCont"/></WeightWithCont>
			</xsl:if>	
			<xsl:if test="string-length(PlacesDescription)>0">
				<PackingDescription><xsl:value-of select="PlacesDescription"/></PackingDescription>
			</xsl:if>	
			<xsl:choose>
				<xsl:when test="string-length($numdatdoc)>0">
					<xsl:for-each select="//*[name()='CONOSAMENTGOODS_ITEM' or name()='CONOSAMENTGoods_ITEM'][concat(../../RegNum,substring(../../RegDate,1,10),GoodsNomenclatureCode,GoodsDescription)=$groupgoods][string-length(ContainerNum)>0]/ContainerNum">
						<Container>
							<ContainerNum><xsl:value-of select="."/></ContainerNum>
							<xsl:variable name="numcont" select="."/>
							<xsl:for-each select="../../*[name()='CONOSAMENTGOODS_ITEM' or name()='CONOSAMENTGoods_ITEM'][concat(../../RegNum,substring(../../RegDate,1,10),GoodsNomenclatureCode,GoodsDescription,ContainerNum)=concat($groupgoods,$numcont) ]">
							<xsl:if test="string-length(Seals)>0">
								<xsl:call-template name="SealsNodeForConosament">
									<xsl:with-param name="NameSl">Seals</xsl:with-param>
									<xsl:with-param name="NameSp">urn:customs.ru:Information:TransportDocuments:Sea:BillofLading:5.24.0</xsl:with-param>
									<xsl:with-param name="NameNode">Seal</xsl:with-param>
									<xsl:with-param name="LenDes" select="50"/>				
								</xsl:call-template>
							</xsl:if>
							</xsl:for-each>
							<xsl:if test="string-length(../TotalSealNumber)>0">
								<TotalSealNumber><xsl:value-of select="../TotalSealNumber"/></TotalSealNumber>
							</xsl:if>	
						</Container>
					</xsl:for-each>
				</xsl:when>
				<xsl:otherwise>
					<xsl:if test="string-length(ContainerNum)>0">
						<Container>
							<ContainerNum><xsl:value-of select="ContainerNum"/></ContainerNum>
							<xsl:if test="string-length(Seals)>0">
								<xsl:call-template name="SealsNodeForConosament">
									<xsl:with-param name="NameSl">Seals</xsl:with-param>
									<xsl:with-param name="NameSp">urn:customs.ru:Information:TransportDocuments:Sea:BillofLading:5.24.0</xsl:with-param>
									<xsl:with-param name="NameNode">Seal</xsl:with-param>
									<xsl:with-param name="LenDes" select="50"/>				
								</xsl:call-template>
							</xsl:if>
							<xsl:if test="string-length(TotalSealNumber)>0">
								<TotalSealNumber><xsl:value-of select="TotalSealNumber"/></TotalSealNumber>
							</xsl:if>	
						</Container>
					</xsl:if>
				</xsl:otherwise>
			</xsl:choose>
			<xsl:if test="string-length(PolletQuantity)>0">
				<PolletQuantity><xsl:value-of select="PolletQuantity"/></PolletQuantity>
			</xsl:if>
			<xsl:if test="$NotHazCargoCode!=1">
				<xsl:choose>
					<xsl:when test="count(Danger/DANGER_ITEM[string-length(UNNO)>0])>0">
						<xsl:for-each select="Danger/DANGER_ITEM[string-length(UNNO)>0]">
							<UNnumber><xsl:value-of select="UNNO"/></UNnumber>
						</xsl:for-each>	
					</xsl:when>
					<xsl:when test="string-length(UNNO)>0">
						<UNnumber><xsl:value-of select="UNNO"/></UNnumber>
					</xsl:when>
				</xsl:choose>
			</xsl:if>
		</Goods>
	</xsl:template>

	<xsl:key use="concat(../../RegNum,substring(../../RegDate,1,10),./GoodsNomenclatureCode,./GoodsDescription)" name="GoodsConosCont" match="//*[name()='CONOSAMENTGOODS_ITEM' or name()='CONOSAMENTGoods_ITEM']"/>
	<xsl:key use="concat(../../RegNum,substring(../../RegDate,1,10),./GoodsNomenclatureCode,./GoodsDescription,./ContainerNum)" name="GoodsConosContC" match="//*[name()='CONOSAMENTGOODS_ITEM' or name()='CONOSAMENTGoods_ITEM']"/>
	<xsl:template name="CONOSAMENT">	
		<xsl:variable name="NameNode" select ="CONOSAMENTGoods/*[name()='CONOSAMENTGOODS_ITEM' or name()='CONOSAMENTGoods_ITEM']"/>		
		<xsl:variable name="CnNum" select="RegNum"/>
		<BillofLading xmlns="urn:customs.ru:Information:TransportDocuments:Sea:BillofLading:5.24.0" xmlns:cat_ru="urn:customs.ru:CommonAggregateTypes:5.24.0" xmlns:catTrans_ru="urn:customs.ru:Information:TransportDocuments:TransportCommonAgregateTypesCust:5.24.0" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" DocumentModeID="1003202E">
			<cat_ru:DocumentID>00000000-0000-0000-0000-000000000000</cat_ru:DocumentID>
			<xsl:choose>
				<xsl:when test="string-length(LanguageCode)>0">
					<LanguageCode><xsl:value-of select="LanguageCode"/></LanguageCode>
				</xsl:when>
				<xsl:otherwise>
					<LanguageCode>EN</LanguageCode>
				</xsl:otherwise>
			</xsl:choose>
			<xsl:if test="string-length(CopyNumber)>0">
				<CopyNumber><xsl:value-of select="CopyNumber"/></CopyNumber>
			</xsl:if>
			<xsl:if test="string-length(Clause)>0">
				<Clause><xsl:value-of select="Clause"/></Clause>
			</xsl:if>
			<xsl:if test="string-length(BOLDescription)>0">
				<BOLDescription><xsl:value-of select="BOLDescription"/></BOLDescription>
			</xsl:if>
			<RegistrationDocument>
				<xsl:if test="string-length(ConosamentName)>0">
					<cat_ru:PrDocumentName><xsl:value-of select="ConosamentName"/></cat_ru:PrDocumentName>
				</xsl:if>
				<xsl:if test="string-length($CnNum)>0">
					<cat_ru:PrDocumentNumber><xsl:value-of select="$CnNum"/></cat_ru:PrDocumentNumber>
				</xsl:if>
				<xsl:if test="string-length(RegDate)>0">
					<cat_ru:PrDocumentDate>
						<xsl:call-template name="TranslateDate">
							<xsl:with-param name="Dat" select="RegDate"/>
						</xsl:call-template>
					</cat_ru:PrDocumentDate>
				</xsl:if>
				<xsl:if test="string-length(Place)>0">
					<Place><xsl:value-of select="substring(Place,1,40)"/></Place>
				</xsl:if>
			</RegistrationDocument>
			<Vessel>
				<catTrans_ru:Name><xsl:value-of select="VesselName"/></catTrans_ru:Name>
				<xsl:if test="string-length(VesselShipmaster)>0">
					<catTrans_ru:Shipmaster><xsl:value-of select="VesselShipmaster"/></catTrans_ru:Shipmaster>
				</xsl:if>
				<xsl:if test="string-length(VesselNationalityCode)>0">
					<xsl:variable name="VesCr" select="string(number(VesselNationalityCode))='NaN'"/>
					<xsl:variable name="VesselNationalityCode" select="VesselNationalityCode"/>
					<xsl:choose>
						<xsl:when test="$VesCr">
							<catTrans_ru:NationalityCode><xsl:value-of select="$NsiCon//Country_ITEM[ABC2=$VesselNationalityCode]/Code"/></catTrans_ru:NationalityCode>
							<catTrans_ru:NationalityVessel><xsl:value-of select="$NsiCon//Country_ITEM[ABC2=$VesselNationalityCode]/Name"/></catTrans_ru:NationalityVessel>
							<catTrans_ru:NationalityVesselCode><xsl:value-of select="VesselNationalityCode"/></catTrans_ru:NationalityVesselCode>
						</xsl:when>
						<xsl:otherwise>
							<catTrans_ru:NationalityCode><xsl:value-of select="VesselNationalityCode"/></catTrans_ru:NationalityCode>
							<catTrans_ru:NationalityVessel><xsl:value-of select="$NsiCon//Country_ITEM[Code=$VesselNationalityCode]/Name"/></catTrans_ru:NationalityVessel>
							<catTrans_ru:NationalityVesselCode><xsl:value-of select="$NsiCon//Country_ITEM[Code=$VesselNationalityCode]/ABC2"/></catTrans_ru:NationalityVesselCode>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:if>
			</Vessel>
			<Loading>
				<xsl:if test="string-length(LoadingDate)>0">
					<catTrans_ru:Date><xsl:value-of select="substring(LoadingDate,1,10)"/></catTrans_ru:Date>
				</xsl:if>
				<catTrans_ru:Name><xsl:value-of select="substring(normalize-space(LoadingName),1,50)"/></catTrans_ru:Name>
				<xsl:if test="string-length(LoadingTransferTime)>0">
					<TransferTime><xsl:value-of select="LoadingTransferTime"/></TransferTime>
				</xsl:if>
			</Loading>
			<Unloading>
				<xsl:if test="string-length(UnloadingDate)>0">
					<catTrans_ru:Date><xsl:value-of select="substring(UnloadingDate,1,10)"/></catTrans_ru:Date>
				</xsl:if>
				<catTrans_ru:Name><xsl:value-of select="substring(normalize-space(UnloadingName),1,50)"/></catTrans_ru:Name>
				<xsl:if test="string-length(UnloadingTransferTime)>0">
					<TransferTime><xsl:value-of select="UnloadingTransferTime"/></TransferTime>
				</xsl:if>
			</Unloading>
			<Carrier>
				<xsl:call-template name="FirmNodeConstr">
					<xsl:with-param name="Pref">Carrier_</xsl:with-param>
					<xsl:with-param name="NameSp">urn:customs.ru:CommonAggregateTypes:5.24.0</xsl:with-param>
					<xsl:with-param name="NamspNode">urn:customs.ru:CommonAggregateTypes:5.24.0</xsl:with-param>
					<xsl:with-param name="NodeNameAdr">cat_ru:Address</xsl:with-param>
					<xsl:with-param name="NodeNameContact">cat_ru:Contact</xsl:with-param>
					<xsl:with-param name="RwC">1</xsl:with-param>
				</xsl:call-template>
			</Carrier>
			<xsl:if test="string-length(Consignee_Name)>0">
				<Consignee>
					<xsl:call-template name="FirmNodeConstr">
						<xsl:with-param name="Pref">Consignee_</xsl:with-param>
						<xsl:with-param name="NameSp">urn:customs.ru:CommonAggregateTypes:5.24.0</xsl:with-param>
						<xsl:with-param name="NamspNode">urn:customs.ru:CommonAggregateTypes:5.24.0</xsl:with-param>
						<xsl:with-param name="NodeNameAdr">cat_ru:Address</xsl:with-param>
						<xsl:with-param name="NodeNameContact">cat_ru:Contact</xsl:with-param>
						<xsl:with-param name="RwC">1</xsl:with-param>
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
						<xsl:with-param name="RwC">1</xsl:with-param>
				</xsl:call-template>
			</Consignor>
			<xsl:if test="string-length(FrDescription)>0 or string-length(FreightAmount)>0">
				<Freight>
					<xsl:if test="string-length(FrDescription)>0">
						<FrDescription><xsl:value-of select="FrDescription"/></FrDescription>
					</xsl:if>
					<xsl:if test="string-length(FreightAmount)>0">
						<FreightAmount><xsl:value-of select="FreightAmount"/></FreightAmount>
					</xsl:if>
				</Freight>
			</xsl:if>
			<xsl:if test="string-length(Destination_Name)>0">
				<Destination>
					<xsl:if test="string-length(Destination_Name)>0">
						<Name><xsl:value-of select="Destination_Name"/></Name>
					</xsl:if>
					<xsl:choose>
						<xsl:when test="string-length(Destination_PostalCode)>0 or string-length(Destination_CountryCode)>0 or string-length(Destination_CountryName)>0 or string-length(Destination_Region)>0 or string-length(Destination_City)>0 or string-length(Destination_StreetHouse)>0">
							<xsl:call-template name="Address">
								<xsl:with-param name="Pref">Destination_</xsl:with-param>
								<xsl:with-param name="NodeName">Address</xsl:with-param>
								<xsl:with-param name="Namsp">urn:customs.ru:CommonAggregateTypes:5.24.0</xsl:with-param>
								<xsl:with-param name="NamspNode">urn:customs.ru:Information:TransportDocuments:Sea:BillofLading:5.24.0</xsl:with-param>
							</xsl:call-template>
						</xsl:when>
						<xsl:otherwise>
							<Address/>
						</xsl:otherwise>
					</xsl:choose>
				</Destination>
			</xsl:if>
			<xsl:variable name="numdat-doc" select="concat(RegNum,substring(RegDate,1,10))"/>
			<xsl:variable name="count_cont" select="count(//*[name()='CONOSAMENTGOODS_ITEM' or name()='CONOSAMENTGoods_ITEM'][generate-id(.)=generate-id(key('GoodsConosContC',concat($numdat-doc,./GoodsNomenclatureCode,./GoodsDescription,./ContainerNum)))][string-length(ContainerNum)>0]/ContainerNum)"/>
			
			<xsl:choose>
				<xsl:when test="$count_cont>1 and string-length(LoadFts)>0 and number(LoadFts)=1">
					<xsl:for-each select="//*[name()='CONOSAMENTGOODS_ITEM' or name()='CONOSAMENTGoods_ITEM'][generate-id(.)=generate-id(key('GoodsConosCont',concat($numdat-doc,./GoodsNomenclatureCode,./GoodsDescription)))]">
						<xsl:call-template name="ConosamentGoods">
							<xsl:with-param name="numdatdoc" select="$numdat-doc"/>
						</xsl:call-template>
					</xsl:for-each>
				</xsl:when>
				<xsl:otherwise>
					<xsl:for-each select="$NameNode">
						<xsl:call-template name="ConosamentGoods"/>
					</xsl:for-each>
				</xsl:otherwise>
			</xsl:choose>
			<DocumentSignature>
				<xsl:choose>
					<xsl:when test="string-length(DocSig_PersonName)>0 or string-length(DocSig_PersonName2)>0">
						<xsl:variable name="PersonName">
							<xsl:value-of select="concat(DocSig_PersonName,' ',DocSig_PersonName2)"/>
							<xsl:if test="string-length(DocSig_PersonMiddleName)>0">
								<xsl:value-of select="DocSig_PersonMiddleName"/>
							</xsl:if>
						</xsl:variable>
						<PersonName><xsl:value-of select="normalize-space($PersonName)"/></PersonName>	
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
			<xsl:if test="string-length(PlaceOfDelivery_City)>0">
				<PlaceOfDelivery>
					<City>
						<xsl:choose>
							<xsl:when test="string-length(PlaceOfDelivery_City)>35">
								<xsl:value-of select="substring(PlaceOfDelivery_City,1,35)"/>
							</xsl:when>
							<xsl:otherwise>
								<xsl:value-of select="PlaceOfDelivery_City"/>
							</xsl:otherwise>
						</xsl:choose>
					</City>
					<xsl:if test="string-length(PlaceOfDelivery_CountryName)>0">
						<CountryName><xsl:value-of select="PlaceOfDelivery_CountryName"/></CountryName>
					</xsl:if>
				</PlaceOfDelivery>
			</xsl:if>
			<xsl:if test="string-length(PlaceOfReceipt_City)>0">
				<PlaceOfReceipt>
					<City>
						<xsl:choose>
							<xsl:when test="string-length(PlaceOfReceipt_City)>35">
								<xsl:value-of select="substring(PlaceOfReceipt_City,1,35)"/>
							</xsl:when>
							<xsl:otherwise>
								<xsl:value-of select="PlaceOfReceipt_City"/>
							</xsl:otherwise>
						</xsl:choose>
					</City>
					<xsl:if test="string-length(PlaceOfReceipt_CountryName)>0">
						<CountryName><xsl:value-of select="PlaceOfReceipt_CountryName"/></CountryName>
					</xsl:if>
				</PlaceOfReceipt>
			</xsl:if>
			<xsl:if test="string-length(MarkKind)>0">
				<Mark>
					<MarkSing>true</MarkSing>
					<MarkKind><xsl:value-of select="MarkKind"/></MarkKind>
					<xsl:if test="string-length(ResultControl)>0">
						<ResultControl><xsl:value-of select="ResultControl"/></ResultControl>
					</xsl:if>	
				</Mark>
			</xsl:if>
			<xsl:for-each select="COMMISSIONSHIPMENTDOC/COMMISSIONSHIPMENTDOC_ITEM[string-length(normalize-space(concat(PrDocumentName,PrDocumentNumber,PrDocumentDate)))>0]">
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
	</xsl:template>
</xsl:stylesheet>
