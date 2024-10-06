<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:docs="https://documents.ru">
	<xsl:include href="../../COMMON/function_for_server.xsl"/>
	<xsl:output method="xml"/>
	<xsl:template match="/">
		<xsl:apply-templates select="//Package"/>
	</xsl:template>
	<xsl:variable name="PathNsiInv" select="document('../../NSI/TranspNSIXml.xml')"/>
	<xsl:variable name="CodeCountryWH">,RU,BY,KZ,AM,KG,</xsl:variable>
	<xsl:template match="Package">
		<xsl:if test="count(//WHDOCINVENTORY)>0">
			<ResultInformation xmlns:docs="https://documents.ru">
				<xsl:call-template name="flk_wh_doc">
					<xsl:with-param name="PathWh" select="WHDOCINVENTORY/WHDOCINVENTORY_ITEM/InventDocument/INVENTDOCUMENT_ITEM"/>
					<xsl:with-param name="PathWhErr" select="'WHDOCINVENTORY/WHDOCINVENTORY_ITEM/InventDocument/INVENTDOCUMENT_ITEM'"/>
				</xsl:call-template>
			</ResultInformation>
		</xsl:if>
	</xsl:template>
	<xsl:template name="ErrorNode">
		<xsl:param name="MessErr"/>
		<xsl:param name="PathErr"/>
		<xsl:param name="Category"/>
		<xsl:param name="Num"/>
		<xsl:variable name="Cat">
			<xsl:choose>
				<xsl:when test="string-length($Category)=0">ERROR</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="$Category"/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<xsl:variable name="name_cfg" select="ancestor::*/@*[local-name()='CfgName']"/>
		<RESULTINFORMATION_ITEM xmlns:docs="https://documents.ru">
			<ResultDescription><xsl:copy-of select="$MessErr"/></ResultDescription>
			<ResultIdDocument><xsl:value-of select="ancestor::*[@*[local-name()='CfgName']]/@id"/></ResultIdDocument>
			<ResultTypeDocument><xsl:value-of select="ancestor::*/@*[local-name()='CfgName']"/></ResultTypeDocument>
			<ResultPosInPkgDocument><xsl:value-of select="count(ancestor::*[@*[local-name()='CfgName']]/preceding-sibling::*[@*[local-name()='CfgName']=$name_cfg])+1"/></ResultPosInPkgDocument>
			<ResultPathNode><xsl:value-of select="$PathErr"/></ResultPathNode>
			<ResultCategory><xsl:value-of select="$Cat"/></ResultCategory>
			<DocumentNumber><xsl:value-of select="$Num"/></DocumentNumber>
		</RESULTINFORMATION_ITEM>
	</xsl:template>
		
	<xsl:template name="flk_wh_doc" xmlns:docs="https://documents.ru">
		<xsl:param name="PathWh"/>
		<xsl:param name="PathWhErr"/>
		<xsl:for-each select="child::*[namespace::*='http://documents.ru'][string-length(@*[local-name()='CfgName'])>0][string-length(@DocumentModeID)=0][not(contains(@*[local-name()='CfgName'],'html.cfg.xml'))][not(contains(name(),'DesNotif_PIResult'))]">
				<xsl:variable name="NameNode" select="name()"/>
				<xsl:variable name="NodePath" select="concat(name(),'/',name(),'_ITEM')"/>
				<xsl:for-each select="child::*">
					<xsl:if test="contains($NameNode,'INVENTORY') and count(InventDocument/INVENTDOCUMENT_ITEM[count(child::*[string-length(.)>0])>0])=0">
						<xsl:call-template name="ErrorNode">
							<xsl:with-param name="MessErr">В документе Опись отсутствуют предоставляемые документы</xsl:with-param>
							<xsl:with-param name="PathErr" select="concat($NodePath, '/InventDocument/INVENTDOCUMENT_ITEM[1]/InvDocCode')"/>
						</xsl:call-template>
					</xsl:if>
					<xsl:choose>
						<xsl:when test="contains($NameNode,'WHDOCINVENTORY')">
							<xsl:if test="string-length(InventoryInstanceDate)=0">
								<xsl:call-template name="ErrorNode">
									<xsl:with-param name="MessErr">Пакет содержит Опись СВХ с незаполненным полем Дата предоставления описи.</xsl:with-param>
									<xsl:with-param name="PathErr">WHDOCINVENTORY/WHDOCINVENTORY_ITEM/InventoryInstanceDate</xsl:with-param>
								</xsl:call-template>
							</xsl:if>
							<xsl:if test="string-length(Participant_CountryCode)=0">
								<xsl:call-template name="ErrorNode">
									<xsl:with-param name="MessErr">В документе Опись СВХ не заполнено поле Лицо, представляющее документы для помещения товаров на ВХ: буквенный код страны.</xsl:with-param>
									<xsl:with-param name="PathErr">WHDOCINVENTORY/WHDOCINVENTORY_ITEM/Participant_CountryCode</xsl:with-param>
								</xsl:call-template>
							</xsl:if>
							<xsl:if test="string-length(Participant_CountryCode)>0 and not(contains(translate(Participant_CountryCode,$uppercaseeng,$engtext),'zz'))">
								<xsl:call-template name="ErrorNode">
									<xsl:with-param name="MessErr">В документе Опись СВХ значение в поле Лицо, представляющее документы для помещения товаров на ВХ: буквенный код страны не соответствует формату (д.б. 2 лат.буквы в верхнем регистре)</xsl:with-param>
									<xsl:with-param name="PathErr">WHDOCINVENTORY/WHDOCINVENTORY_ITEM/Participant_CountryCode</xsl:with-param>
								</xsl:call-template>
							</xsl:if>
							<xsl:if test="string-length(Participant_OGRN)>0 and string-length(Participant_CountryCode)>0">
								<xsl:variable name="PartRu" select="Participant_CountryCode='RU' and string-length(Participant_OGRN)!=13 and string-length(Participant_OGRN)!=15"/>
								<xsl:variable name="PartKz" select="Participant_CountryCode='KZ' and string-length(Participant_OGRN)!=12"/>
								<xsl:if test="$PartRu or $PartKz">
									<xsl:call-template name="ErrorNode">
										<xsl:with-param name="MessErr">В документе Опись СВХ значение в поле Лицо, представляющее документы для помещения товаров на ВХ: ОГРН не соответствует формату (кода страны RU - д.б.13 или 15 цифр, для KZ - 12)</xsl:with-param>
										<xsl:with-param name="PathErr">WHDOCINVENTORY/WHDOCINVENTORY_ITEM/Participant_OGRN</xsl:with-param>
									</xsl:call-template>
								</xsl:if>
							</xsl:if>
							<xsl:if test="string-length(Participant_KPP)>0 and string-length(Participant_KPP)!=9 and string-length(Participant_CountryCode)>0 and Participant_CountryCode='RU'">
								<xsl:call-template name="ErrorNode">
									<xsl:with-param name="MessErr">В документе Опись СВХ значение в поле Лицо, представляющее документы для помещения товаров на ВХ: КПП не соответствует формату  (д.б. 9 цифр)</xsl:with-param>
									<xsl:with-param name="PathErr">WHDOCINVENTORY/WHDOCINVENTORY_ITEM/Participant_KPP</xsl:with-param>
								</xsl:call-template>
							</xsl:if>
							<xsl:if test="string-length(Participant_Name)=0">
								<xsl:call-template name="ErrorNode">
									<xsl:with-param name="MessErr">В документе Опись СВХ не заполнено поле Лицо, представляющее документы для помещения товаров на ВХ: наименование.</xsl:with-param>
									<xsl:with-param name="PathErr">WHDOCINVENTORY/WHDOCINVENTORY_ITEM/Participant_Name</xsl:with-param>
								</xsl:call-template>
							</xsl:if>
							<xsl:if test="string-length(Carrier_CountryCode)=0">
								<xsl:call-template name="ErrorNode">
									<xsl:with-param name="MessErr">В документе Опись СВХ не заполнено поле Перевозчик: буквенный код страны</xsl:with-param>
									<xsl:with-param name="PathErr">WHDOCINVENTORY/WHDOCINVENTORY_ITEM/Carrier_CountryCode</xsl:with-param>
								</xsl:call-template>
							</xsl:if>
							<xsl:if test="string-length(Receiver_Customs_Code)=0">
								<xsl:call-template name="ErrorNode">
									<xsl:with-param name="MessErr">В документе Опись СВХ не заполнено поле Получатель:Код таможенного органа</xsl:with-param>
									<xsl:with-param name="PathErr">WHDOCINVENTORY/WHDOCINVENTORY_ITEM/Receiver_Customs_Code</xsl:with-param>
								</xsl:call-template>
							</xsl:if>
						</xsl:when>
						<xsl:when test="contains($NameNode,'ARRSEADECL')">
							<xsl:for-each select="ARRSEADECLGoods/ARRSEADECLGOODS_ITEM">
								<xsl:if test="string-length(ConosamentNum)=0">
									<xsl:call-template name="ErrorNode">
										<xsl:with-param name="MessErr" select="'Пакет содержит документ Декларацию о приходе/отходе судна с коносаментом, у котрого не заполнен Номер документа.'"/>
										<xsl:with-param name="PathErr" select="concat($NodePath,'/ARRSEADECLGoods/ARRSEADECLGOODS_ITEM[',position(),']/ConosamentNum')"/>
									</xsl:call-template>
								</xsl:if>
							</xsl:for-each>
						</xsl:when>
					</xsl:choose>
				</xsl:for-each>
			</xsl:for-each>
		
			<xsl:call-template name="DublDocInWHInventory">
				<xsl:with-param name="NameNode" select="$PathWh"/>
				<xsl:with-param name="PathWhErr" select="$PathWhErr"/>
			</xsl:call-template>
			<xsl:for-each select="$PathWh">
				<xsl:variable name="PosD" select="position()"/>
				<xsl:variable name="DocCode" select="InvDocCode"/>
				<xsl:variable name="NumDat" select="concat(InvDocNumber,substring(InvDocDate,1,10))"/>
				<xsl:variable name="NumDoc" select="InvDocNumber"/>
				<xsl:variable name="DocNamInv" select="Note"/>
				<xsl:variable name="DocPathErr" select="concat($PathWhErr,'[',$PosD,']/InvDocCode')"/>
				<xsl:choose>
					<xsl:when test="string-length($DocCode)=0 and string-length($PathWhErr)>0">
						<xsl:call-template name="ErrorNode">
							<xsl:with-param name="MessErr">Опись СВХ содержит документ с незаполненным кодом</xsl:with-param>
							<xsl:with-param name="PathErr" select="concat($PathWhErr,'[',$PosD,']/InvDocCode')"/>
						</xsl:call-template>
					</xsl:when>
					<xsl:otherwise>
						<xsl:if test="string-length($DocCode)!=5 or ($DocCode!='00000' and string-length($PathNsiInv//DOCG44_ITEM[CODE=$DocCode]/CODE)=0)">
							<xsl:call-template name="ErrorNode">
								<xsl:with-param name="MessErr">Опись СВХ содержит документ, код которого отсутствует в справочнике</xsl:with-param>
								<xsl:with-param name="PathErr" select="$DocPathErr"/>
							</xsl:call-template>
						</xsl:if>
						<xsl:variable name="NodeUsl">
							<xsl:call-template name="ChDocNode">
								<xsl:with-param name="DocNam">CONOSAMENT</xsl:with-param>
								<xsl:with-param name="NumDat" select="$NumDat"/>
								<xsl:with-param name="DocNamInv" select="$DocNamInv"/>
							</xsl:call-template>
						</xsl:variable>
						<xsl:if test="string-length(DocumentFormSign)=0 or (string-length(DocumentFormSign)>0 and number(DocumentFormSign)!=1)">
							<xsl:if test="$NodeUsl=0">
								<xsl:variable name="ConosArr">
									<xsl:choose>
										<xsl:when test="$DocCode='02011' and count(//ARRSEADECL/ARRSEADECL_ITEM)=0 and count(//EDTRANSIT_INVENTORY)=0">0</xsl:when>
										<xsl:when test="$DocCode='02011' and count(//ARRSEADECL/ARRSEADECL_ITEM)>0">
											<xsl:value-of select="count(//ARRSEADECLGOODS_ITEM[concat(ConosamentNum,substring(ConosamentDate,1,10))=$NumDat])"/>
										</xsl:when>
										<xsl:otherwise>0</xsl:otherwise>
									</xsl:choose>
								</xsl:variable>
								<xsl:if test="$ConosArr=0">
									<xsl:call-template name="ErrorNode">
										<xsl:with-param name="MessErr">Опись СВХ содержит опечатку в номере, дате или коде представленного документа, или такой документ отсутствует в пакете.</xsl:with-param>
										<xsl:with-param name="PathErr" select="$DocPathErr"/>
									</xsl:call-template>
								</xsl:if>
							</xsl:if>
						</xsl:if>
						<xsl:if test="DocumentFormSign!=1 and string-length(InvDocName)=0 and string-length(Note)=0">
							<xsl:call-template name="ErrorNode">
								<xsl:with-param name="MessErr">Опись СВХ содержит документ с незаполненным полем Наименование документа.</xsl:with-param>
								<xsl:with-param name="PathErr" select="concat($PathWhErr,'[',$PosD,']/Note')"/>
							</xsl:call-template>
						</xsl:if>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:for-each>
	</xsl:template>
	
	<xsl:template name="ChDocNode">
		<xsl:param name="DocNam"/>
		<xsl:param name="NumDat"/>
		<xsl:param name="DocNamInv"/>
		<xsl:variable name="NodeN">
			<xsl:choose>
				<xsl:when test="contains($DocNam,',')">
					<xsl:value-of select="substring-before($DocNam,',')"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="$DocNam"/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<xsl:choose>
			<xsl:when test="string-length($NodeN)>0">
				<xsl:variable name="CDoc" select="count(//*[name()=$NodeN]/*[name()=concat($NodeN,'_ITEM')][concat(RegNum,substring(RegDate,1,10))=$NumDat])"/>
				<xsl:variable name="AllCDoc" select="count(//*[name()=$NodeN]/*[name()=concat($NodeN,'_ITEM')])"/>
				<xsl:variable name="LNodeN" select="substring-after($DocNam,',')"/>
				<xsl:choose>
					<xsl:when test="string-length($LNodeN)=0">0</xsl:when>
					<xsl:when test="$CDoc>0">1</xsl:when>
					<xsl:otherwise>
						<xsl:choose>
							<xsl:when test="string-length($LNodeN)>0">
								<xsl:call-template name="ChDocNode">
									<xsl:with-param name="DocNam" select="$LNodeN"/>
									<xsl:with-param name="NumDat" select="$NumDat"/>
								</xsl:call-template>
							</xsl:when>
							<xsl:otherwise>0</xsl:otherwise>
						</xsl:choose>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:when>
			<xsl:otherwise>0</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	
	<xsl:template name="DublDocInWHInventory" xmlns:docs="https://documents.ru">
		<xsl:param name="NameNode"/>
		
		<xsl:param name="PathWhErr"/>
		<xsl:for-each select="$NameNode">
			<xsl:variable name="full-num-doc" select="concat(InvDocCode,InvDocNumber,Note,substring(InvDocDate,1,10))"/>
			<xsl:variable name="pos-doc" select="position()"/>
			<xsl:variable name="next-full-num-doc" select="count($NameNode[concat(InvDocCode,InvDocNumber,Note,substring(InvDocDate,1,10))=$full-num-doc])"/>
			<xsl:if test="$next-full-num-doc>1">
				<xsl:call-template name="ErrorNode">
					<xsl:with-param name="MessErr">Опись СВХ содержит несколько одинаковых документов</xsl:with-param>
					<xsl:with-param name="PathErr" select="concat($PathWhErr,'[',$pos-doc,']/InvDocCode')"/>
				</xsl:call-template>
			</xsl:if>
		</xsl:for-each>
	</xsl:template>
	
</xsl:stylesheet>
