<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
   	<xsl:output method="xml"/>
	<xsl:variable name="new-line">
		<xsl:text>&#xA;</xsl:text>
	</xsl:variable>
	<xsl:variable name="uppercaseeng" select="'ABCDEFGHIJKLMNOPQRSTUVWXYZ'"/>
	<xsl:variable name="smallcaseeng" select="'abcdefghijklmnopqrstuvwxyz'"/>
	<xsl:variable name="smallcaserus" select="'йцукенгшщзхъёфывапролджэячсмитьбю'"/>
	<xsl:variable name="uppercaserus" select="'ЙЦУКЕНГШЩЗХЪЁФЫВАПРОЛДЖЭЯЧСМИТЬБЮ'"/>
	<xsl:variable name="engtext">zzzzzzzzzzzzzzzzzzzzzzzzzz</xsl:variable>
    <xsl:variable name="rustext">zzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz</xsl:variable>
	<xsl:variable name="NsiPathFunc" select="document('../NSI/TranspNSIXml.xml')"/>
	
	<xsl:template name="FirmNodeConstr">
		<xsl:param name="Pref"/>
		<xsl:param name="NameSp"/>
		<xsl:param name="NamspNode"/>
		<xsl:param name="NamspNodeAdr"/>
		<xsl:param name="NamspNodeContact"/>
		<xsl:param name="NamspNodeIdentityCard"/>
		<xsl:param name="NodeNameAdr"/>
		<xsl:param name="NodeNameContact"/>
		<xsl:param name="NodeNameIdentityCard"/>
		<xsl:call-template name="OrgNode">
			<xsl:with-param name="Pref" select="$Pref"/>
			<xsl:with-param name="NameSp" select="$NameSp"/>
			<xsl:with-param name="NamspNode" select="$NamspNode"/>
		</xsl:call-template>
		<xsl:call-template name="OKPONode">
			<xsl:with-param name="Pref" select="$Pref"/>
			<xsl:with-param name="Namsp" select="$NameSp"/>
		</xsl:call-template>
		<xsl:call-template name="Contact">
			<xsl:with-param name="Pref" select="$Pref"/>
			<xsl:with-param name="NodeName" select="$NodeNameContact"/>
			<xsl:with-param name="Namsp" select="$NameSp"/>
			<xsl:with-param name="NamspNode">
				<xsl:choose>
					<xsl:when test="string-length($NamspNodeContact)>0">
						<xsl:value-of select="$NamspNodeContact"/>
					</xsl:when>
					<xsl:otherwise>
						<xsl:value-of select="$NamspNode"/>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:with-param>
		</xsl:call-template>
		<xsl:call-template name="Address">
			<xsl:with-param name="Pref" select="$Pref"/>
			<xsl:with-param name="NodeName" select="$NodeNameAdr"/>
			<xsl:with-param name="Namsp" select="$NameSp"/>
			<xsl:with-param name="NamspNode">
				<xsl:choose>
					<xsl:when test="string-length($NamspNodeAdr)>0">
						<xsl:value-of select="$NamspNodeAdr"/>
					</xsl:when>
					<xsl:otherwise>
						<xsl:value-of select="$NamspNode"/>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:with-param>
		</xsl:call-template>
		<xsl:choose>
			<xsl:when test="contains($NodeNameContact,'catSert')">
				<xsl:call-template name="ContactNode">
					<xsl:with-param name="Namsp" select="$NamspNodeContact"/>
					<xsl:with-param name="Pref" select="$Pref"/>
					<xsl:with-param name="PrefNode" select="$NodeNameContact"/>
				</xsl:call-template>
			</xsl:when>
			<xsl:otherwise>
				<xsl:call-template name="Contact">
					<xsl:with-param name="Pref" select="$Pref"/>
					<xsl:with-param name="NodeName" select="$NodeNameContact"/>
					<xsl:with-param name="Namsp" select="$NameSp"/>
					<xsl:with-param name="NamspNode">
						<xsl:choose>
							<xsl:when test="string-length($NamspNodeContact)>0">
								<xsl:value-of select="$NamspNodeContact"/>
							</xsl:when>
							<xsl:otherwise>
								<xsl:value-of select="$NamspNode"/>
							</xsl:otherwise>
						</xsl:choose>
					</xsl:with-param>
				</xsl:call-template>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	
	<xsl:template name="Address">
		<xsl:param name="Pref"/>
		<xsl:param name="PrefResult"/>
		<xsl:param name="NodeName"/>
		<xsl:param name="Namsp"/>
		<xsl:param name="NamspNode"/>
		<xsl:param name="Phone"/>
		<xsl:param name="PrefResultSp"/>
		<xsl:param name="NoAddressLine" select="false()"/>
		<xsl:param name="NodeAddres"/>
		<xsl:param name="AddressInd"/>
		<xsl:variable name="PrefRes">
			<xsl:choose>
				<xsl:when test="string-length($PrefResult)>0">
					<xsl:value-of select="$PrefResult"/>
				</xsl:when>
				<xsl:otherwise>cat_ru:</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<xsl:variable name="PrefResSp">
			<xsl:choose>
				<xsl:when test="string-length($PrefResultSp)>0">
					<xsl:value-of select="$PrefResultSp"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="$Namsp"/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<xsl:choose>
			<xsl:when test="string-length(*[name()=concat($Pref,'PostalCode')])>0 or string-length(*[name()=concat($Pref,'CountryCode')])>0 or string-length(*[name()=concat($Pref,'LocationCode')])>0 or  string-length(*[name()=concat($Pref,'CountryName')])>0 or	string-length(*[name()=concat($Pref,'Region')])>0 or string-length(*[name()=concat($Pref,'District')])>0  or	string-length(*[name()=concat($Pref,'OKATO')])>0 or string-length(*[name()=concat($Pref,'City')])>0 or string-length(*[name()=concat($Pref,'StreetHouse')])>0 or string-length(*[name()=concat($Pref,'AddressInd')])>0">
				<xsl:element name="{$NodeName}" namespace="{$NamspNode}">
					<xsl:if test="string-length(*[name()=concat($Pref,'PostalCode')])>0">
						<xsl:element name="{concat($PrefRes,'PostalCode')}" namespace="{$PrefResSp}">
							<xsl:value-of select="*[name()=concat($Pref,'PostalCode')]"/>
						</xsl:element>
					</xsl:if>
					<xsl:if test="string-length(*[name()=concat($Pref,'CountryCode')])>0">
						<xsl:element name="{concat($PrefRes,'CountryCode')}" namespace="{$PrefResSp}">
							<xsl:value-of select="*[name()=concat($Pref,'CountryCode')]"/>
						</xsl:element>
					</xsl:if>
					<xsl:if test="string-length(*[name()=concat($Pref,'CountryName')])>0">
						<xsl:element name="{concat($PrefRes,'CounryName')}" namespace="{$PrefResSp}">
							<xsl:variable name="Ctn" select="normalize-space(*[name()=concat($Pref,'CountryName')])"/>
							<xsl:choose>
								<xsl:when test="string-length($Ctn)>40 and not(contains($PrefRes,'RUScat_ru:'))">
									<xsl:value-of select="substring($Ctn,1,40)"/>
								</xsl:when>
								<xsl:when test="string-length($Ctn)>120 and contains($PrefRes,'RUScat_ru:')">
									<xsl:value-of select="substring($Ctn,1,120)"/>
								</xsl:when>
								<xsl:otherwise>
									<xsl:value-of select="$Ctn"/>
								</xsl:otherwise>
							</xsl:choose>
						</xsl:element>
					</xsl:if>
					<xsl:if test="string-length(*[name()=concat($Pref,'Region')])>0">
						<xsl:element name="{concat($PrefRes,'Region')}" namespace="{$PrefResSp}">
							<xsl:variable name="Reg" select="normalize-space(*[name()=concat($Pref,'Region')])"/>
							<xsl:choose>
								<xsl:when test="string-length($Reg)>50 and  not(contains($PrefRes,'RUScat_ru:'))">
									<xsl:value-of select="substring($Reg,1,50)"/>
								</xsl:when>
								<xsl:when test="string-length($Reg)>120 and  contains($PrefRes,'RUScat_ru:') ">
									<xsl:value-of select="substring($Reg,1,120)"/>
								</xsl:when>
								<xsl:otherwise>
									<xsl:value-of select="$Reg"/>
								</xsl:otherwise>
							</xsl:choose>
						</xsl:element>
					</xsl:if>
					<xsl:if test="string-length(*[name()=concat($Pref,'City')])>0">
						<xsl:element name="{concat($PrefRes,'City')}" namespace="{$PrefResSp}">
							<xsl:variable name="Ct" select="normalize-space(*[name()=concat($Pref,'City')])"/>
							<xsl:choose>
								<xsl:when test="string-length($Ct)>35 and not(contains($PrefRes,'RUScat_ru:'))">
									<xsl:value-of select="substring($Ct,1,35)"/>
								</xsl:when>
								<xsl:when test="string-length($Ct)>120 and contains($PrefRes,'RUScat_ru:') ">
									<xsl:value-of select="substring($Ct,1,120)"/>
								</xsl:when>
								<xsl:otherwise>
									<xsl:value-of select="$Ct"/>
								</xsl:otherwise>
							</xsl:choose>
						</xsl:element>
					</xsl:if>
					<xsl:if test="string-length(normalize-space(*[name()=concat($Pref,'StreetHouse')]))>0">
						<xsl:variable name="StH" select="normalize-space(*[name()=concat($Pref,'StreetHouse')])"/>
						<xsl:element name="{concat($PrefRes,'StreetHouse')}" namespace="{$PrefResSp}">
							<xsl:choose>
								<xsl:when test="string-length($StH)>50  and not(contains($PrefRes,'RUScat_ru:'))">
									<xsl:value-of select="substring($StH,1,50)"/>
								</xsl:when>
								<xsl:when test="string-length($StH)>120 and contains($PrefRes,'RUScat_ru:') ">
									<xsl:value-of select="substring($StH,1,120)"/>
								</xsl:when>
								<xsl:otherwise>
									<xsl:value-of select="$StH"/>
								</xsl:otherwise>
							</xsl:choose>
						</xsl:element>
					</xsl:if>
				
					<xsl:if test="string-length(*[name()=concat($Pref,'AddressText')])>0">
						<xsl:element name="{concat($PrefRes,'AddressText')}" namespace="{$PrefResSp}">
							<xsl:value-of select="*[name()=concat($Pref,'AddressText')]"/>
						</xsl:element>
					</xsl:if>
					<xsl:if test="not($NoAddressLine)">
						<xsl:choose>
							<xsl:when test="$NodeName='catWH_ru:Address' and (string-length(*[name()=concat($Pref,'CountryName')])>0 or string-length(*[name()=concat($Pref,'CountryCode')])>0 or string-length(*[name()=concat($Pref,'City')])>0 or string-length(*[name()=concat($Pref,'StreetHouse')])>0)">
								<xsl:variable name="AddrLine">
									<xsl:call-template name="AdresLine">
										<xsl:with-param name="Pref" select="$Pref"/>
									</xsl:call-template>
								</xsl:variable>
								<xsl:if test="string-length($AddrLine)>0">	
									<xsl:element name="{'catWH_ru:AddressLine'}" namespace="{$NamspNode}">
										<xsl:value-of select="$AddrLine"/>
									</xsl:element>
								</xsl:if>	
							</xsl:when>
							<xsl:otherwise>
								<xsl:if test="$NodeName='catWH_ru:Address' and (count(//CONOSAMENT)>0 or count(//ARRSEADECL)>0)">
									<xsl:element name="{'catWH_ru:AddressLine'}" namespace="{$NamspNode}">
										<xsl:value-of select="substring(normalize-space(*[name()=concat($Pref,'Name')]),1,250)"/>
									</xsl:element>
								</xsl:if>
							</xsl:otherwise>
						</xsl:choose>
					</xsl:if>
				</xsl:element>
			</xsl:when>
			<xsl:when test="string-length(*[name()=concat($Pref,'AddressLine')])>0">
				<xsl:element name="{$NodeName}" namespace="{$NamspNode}">
					<xsl:element name="{'catWH_ru:AddressLine'}" namespace="{$NamspNode}">
						<xsl:value-of select="substring(normalize-space(*[name()=concat($Pref,'AddressLine')]),1,250)"/>
					</xsl:element>
				</xsl:element>
			</xsl:when>
			<xsl:when test="string-length(*[name()=concat($Pref,'Name')])>0 and string-length(*[name()=concat($Pref,'PostalCode')])=0 and string-length(*[name()=concat($Pref,'CountryCode')])=0 and string-length(*[name()=concat($Pref,'CountryName')])=0 and string-length(*[name()=concat($Pref,'Region')])=0 and string-length(*[name()=concat($Pref,'City')])=0 and string-length(*[name()=concat($Pref,'StreetHouse')])=0 and $NodeName='catWH_ru:Address' and (count(//CONOSAMENT)>0 or count(//ARRSEADECL)>0)">
				<xsl:element name="{$NodeName}" namespace="{$NamspNode}">
					<xsl:element name="{'catWH_ru:AddressLine'}" namespace="{$NamspNode}">
						<xsl:value-of select="substring(normalize-space(*[name()=concat($Pref,'Name')]),1,250)"/>
					</xsl:element>
				</xsl:element>
			</xsl:when>
			<xsl:when test="string-length(*[name()=concat($Pref,'PostalCode')])=0 and string-length(*[name()=concat($Pref,'CountryCode')])=0 and string-length(*[name()=concat($Pref,'CountryName')])=0 and string-length(*[name()=concat($Pref,'Region')])=0 and string-length(*[name()=concat($Pref,'City')])=0 and string-length(*[name()=concat($Pref,'StreetHouse')])=0 and ($NodeName='catWH_ru:Address' or $NodeAddres=1)">
				<xsl:element name="{$NodeName}" namespace="{$NamspNode}"/>
			</xsl:when>
		</xsl:choose>
	</xsl:template>
	
	<xsl:template name="AdresLine">
		<xsl:param name="Pref"/>
		<xsl:variable name="ValAdd">
			<xsl:if test="string-length(*[name()=concat($Pref,'CountryCode')])>0 and string-length(*[name()=concat($Pref,'CountryName')])=0">
				<xsl:variable name="CodeCr" select="*[name()=concat($Pref,'CountryCode')]"/>
				<xsl:variable name="NameCr" select="$NsiPathFunc//Country_ITEM[ABC2=$CodeCr]/Name"/>
				<xsl:if test="string-length($NameCr)>0">
					<xsl:value-of select="normalize-space($NameCr)"/>
				</xsl:if>
			</xsl:if>
			<xsl:if test="string-length(*[name()=concat($Pref,'CountryName')])>0">
				<xsl:value-of select="normalize-space(*[name()=concat($Pref,'CountryName')])"/>
			</xsl:if>
			<xsl:if test="string-length(*[name()=concat($Pref,'City')])>0">
				<xsl:value-of select="normalize-space(concat(',',*[name()=concat($Pref,'City')]))"/>
			</xsl:if>
			<xsl:if test="string-length(*[name()=concat($Pref,'StreetHouse')])>0">
				<xsl:value-of select="normalize-space(concat(',',*[name()=concat($Pref,'StreetHouse')]))"/>
			</xsl:if>
		</xsl:variable>
		<xsl:variable name="ValAdd1">
			<xsl:choose>
				<xsl:when test="substring($ValAdd,1,1)=','">
					<xsl:value-of select="substring($ValAdd,2)"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="$ValAdd"/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<xsl:choose>
			<xsl:when test="string-length($ValAdd1)>250">
				<xsl:value-of select="substring(normalize-space($ValAdd1),1,250)"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="normalize-space($ValAdd1)"/>
			</xsl:otherwise>
		</xsl:choose>	
	</xsl:template>
	
	<xsl:template name="OrgNode">
		<xsl:param name="Pref"/>
		<xsl:param name="ReqNode"/>
		<xsl:param name="PostalAddress"/>
		<xsl:param name="BLR"/>
		<xsl:param name="NameSp"/>
		<xsl:param name="NamspNode"/>
		<xsl:param name="WHOwner"/>
		<xsl:param name="NamspNodeAdr"/>
		<xsl:param name="PrefResult"/>
		<xsl:param name="PrefResultSp"/>
		<xsl:param name="CRNode"/>
		<xsl:param name="PrName"/>
		<xsl:param name="VerAlb"/>
		<xsl:param name="Okpo"/>
		<xsl:param name="notINN"/>
		<xsl:choose>
			<xsl:when test="$ReqNode">
				<xsl:choose>
					<xsl:when test="string-length($PrName)>0">
						<xsl:variable name="NamePerson">
							<xsl:value-of select="concat(*[name()=concat($Pref,'PersonSurname')],' ',*[name()=concat($Pref,'PersonName')],' ',*[name()=concat($Pref,'PersonMiddleName')])"/>
						</xsl:variable>
						<xsl:element name="{'cat_ru:OrganizationName'}" namespace="{$NameSp}">
							<xsl:choose>
								<xsl:when test="string-length($NamePerson)>150">
									<xsl:value-of select="substring(normalize-space($NamePerson),1,150)"/>
								</xsl:when>
								<xsl:otherwise>
									<xsl:value-of select="normalize-space($NamePerson)"/>
								</xsl:otherwise>
							</xsl:choose>
						</xsl:element>
					</xsl:when>
					<xsl:when test="string-length(*[name()=concat($Pref,'Name')])>0">
						<xsl:element name="{'cat_ru:OrganizationName'}" namespace="{$NameSp}">
							<xsl:choose>
								<xsl:when test="string-length(*[name()=concat($Pref,'Name')])>150">
									<xsl:value-of select="substring(normalize-space(*[name()=concat($Pref,'Name')]),1,150)"/>
								</xsl:when>
								<xsl:otherwise>
									<xsl:value-of select="normalize-space(*[name()=concat($Pref,'Name')])"/>
								</xsl:otherwise>
							</xsl:choose>
						</xsl:element>
					</xsl:when>
					<xsl:otherwise>
						<xsl:element name="{'cat_ru:OrganizationName'}" namespace="{$NameSp}">N</xsl:element>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:when>
			<xsl:otherwise>
				<xsl:if test="string-length(*[name()=concat($Pref,'Name')])>0">
					<xsl:element name="{'cat_ru:OrganizationName'}" namespace="{$NameSp}">
						<xsl:choose>
							<xsl:when test="string-length(*[name()=concat($Pref,'Name')])>150">
								<xsl:value-of select="substring(normalize-space(*[name()=concat($Pref,'Name')]),1,150)"/>
							</xsl:when>
							<xsl:otherwise>
								<xsl:value-of select="normalize-space(*[name()=concat($Pref,'Name')])"/>
							</xsl:otherwise>
						</xsl:choose>
					</xsl:element>
				</xsl:if>
			</xsl:otherwise>
		</xsl:choose>
		<xsl:choose>
			<xsl:when test="(*[name()=concat($Pref,'CountryCode')]='RU' or $CRNode='RU') and (string-length(*[name()=concat($Pref,'OGRN')])>0 or string-length(*[name()=concat($Pref,'INN')])>0 or string-length(*[name()=concat($Pref,'KPP')])>0)">
				<xsl:element name="cat_ru:RFOrganizationFeatures" namespace="{$NameSp}">
					<xsl:if test="string-length(*[name()=concat($Pref,'OGRN')])>0">
						<xsl:element name="{'cat_ru:OGRN'}" namespace="{$NameSp}">
							<xsl:choose>
								<xsl:when test="contains(*[name()=concat($Pref,'OGRN')],'_')">
									<xsl:value-of select="translate(*[name()=concat($Pref,'OGRN')],'_','')"/>								
								</xsl:when>
								<xsl:otherwise>
									<xsl:value-of select="*[name()=concat($Pref,'OGRN')]"/>
								</xsl:otherwise>
							</xsl:choose>
						</xsl:element>
					</xsl:if>
					<xsl:if test="string-length(*[name()=concat($Pref,'INN')])>0">
						<xsl:choose>
							<xsl:when test="string-length(normalize-space(*[name()=concat($Pref,'INN')]))=12 and not(string($notINN))">
								<xsl:element name="{'cat_ru:INN'}" namespace="{$NameSp}">
									<xsl:value-of select="normalize-space(*[name()=concat($Pref,'INN')])"/>
								</xsl:element>	
							</xsl:when>
							<xsl:when test="string-length(normalize-space(*[name()=concat($Pref,'INN')]))>12 and not(string($notINN))">
								<xsl:element name="{'cat_ru:INN'}" namespace="{$NameSp}">
									<xsl:value-of select="substring(normalize-space(*[name()=concat($Pref,'INN')]),1,12)"/>
								</xsl:element>	
							</xsl:when>
							<xsl:when test="not(string($notINN))">
								<xsl:element name="{'cat_ru:INN'}" namespace="{$NameSp}">
									<xsl:value-of select="normalize-space(*[name()=concat($Pref,'INN')])"/>
								</xsl:element>	
							</xsl:when>
						</xsl:choose>
					</xsl:if>
					<xsl:if test="string-length(*[name()=concat($Pref,'KPP')])>0">
						<xsl:element name="{'cat_ru:KPP'}" namespace="{$NameSp}">
							<xsl:value-of select="*[name()=concat($Pref,'KPP')]"/>
						</xsl:element>
					</xsl:if>
				</xsl:element>
			</xsl:when>
			<xsl:when test="*[name()=concat($Pref,'CountryCode')]='BY' and string-length(*[name()=concat($Pref,'INN')])>0">
				<xsl:element name="cat_ru:RBOrganizationFeatures" namespace="{$NameSp}">
					<xsl:if test="string-length(*[name()=concat($Pref,'INN')])>0">
						<xsl:element name="{'cat_ru:UNP'}" namespace="{$NameSp}">
							<xsl:value-of select="substring(normalize-space(*[name()=concat($Pref,'INN')]),1,9)"/>
						</xsl:element>
					</xsl:if>
				</xsl:element>
			</xsl:when>
			<xsl:when test="*[name()=concat($Pref,'CountryCode')]='KZ' and (string-length(*[name()=concat($Pref,'OGRN')])>0 or string-length(*[name()=concat($Pref,'INN')])>0)">
				<xsl:element name="cat_ru:RKOrganizationFeatures" namespace="{$NameSp}">
					<xsl:if test="string-length(*[name()=concat($Pref,'OGRN')])>0">
						<xsl:element name="{'cat_ru:BIN'}" namespace="{$NameSp}">
							<xsl:value-of select="*[name()=concat($Pref,'OGRN')]"/>
						</xsl:element>
					</xsl:if>
					<xsl:if test="string-length(*[name()=concat($Pref,'INN')])>0  and not(string($notINN))">
						<xsl:element name="{'cat_ru:IIN'}" namespace="{$NameSp}">
							<xsl:value-of select="*[name()=concat($Pref,'INN')]"/>
						</xsl:element>
					</xsl:if>
				</xsl:element>
			</xsl:when>
			<xsl:when test="*[name()=concat($Pref,'CountryCode')]='AM' and string-length(*[name()=concat($Pref,'INN')])>0  and not(string($notINN))">
				<xsl:element name="cat_ru:RAOrganizationFeatures" namespace="{$NameSp}">
					<xsl:if test="string-length(*[name()=concat($Pref,'INN')])>0">
						<xsl:element name="{'cat_ru:UNN'}" namespace="{$NameSp}">
							<xsl:value-of select="substring(normalize-space(*[name()=concat($Pref,'INN')]),1,12)"/>
						</xsl:element>
					</xsl:if>
				</xsl:element>
			</xsl:when>
			<xsl:when test="*[name()=concat($Pref,'CountryCode')]='KG' and string-length(*[name()=concat($Pref,'INN')])>0  and not(string($notINN))">
				<xsl:element name="cat_ru:KGOrganizationFeatures" namespace="{$NameSp}">
					<xsl:if test="string-length(*[name()=concat($Pref,'INN')])>0">
						<xsl:element name="{'cat_ru:KGINN'}" namespace="{$NameSp}">
							<xsl:value-of select="substring(normalize-space(*[name()=concat($Pref,'INN')]),1,14)"/>
						</xsl:element>
					</xsl:if>
				</xsl:element>
			</xsl:when>
		</xsl:choose>
		<xsl:if test="string-length($Okpo)>0">
			<xsl:call-template name="OKPONode">
				<xsl:with-param name="Pref" select="$Pref"/>
				<xsl:with-param name="Namsp" select="$NameSp"/>
				<xsl:with-param name="Ver" select="$VerAlb"/>
			</xsl:call-template>
		</xsl:if>
		<xsl:if test="$PostalAddress=4 and $Pref='Carrier_'">
			<xsl:element name="catWH_ru:CountryCode" namespace="{$NamspNodeAdr}">
				<xsl:choose>
					<xsl:when test="string-length(*[name()=concat($Pref,'CountryCodeNum3')])>0">
						<xsl:value-of select="*[name()=concat($Pref,'CountryCodeNum3')]"/>
					</xsl:when>
					<xsl:when test="string-length(*[name()=concat($Pref,'CountryCode')])>0">
						<xsl:variable name="CodeBC" select="*[name()=concat($Pref,'CountryCode')]"/>
						<xsl:value-of select="$NsiPathFunc//Country_ITEM[ABC2=$CodeBC]/Code"/>
					</xsl:when>
					<xsl:when test="string-length(*[name()=concat($Pref,'CountryName')])>0 and contains('ЙЦУКЕНГШЩЗХЪЭЖДЛОРПАВЫФЯЧСМИТЬБЮ',substring(*[name()=concat($Pref,'CountryName')],1,1))">
						<xsl:variable name="CrCr" select="*[name()=concat($Pref,'CountryName')]"/>
						<xsl:value-of select="$NsiPathFunc//Country_ITEM[Name=$CrCr]/Code"/>
					</xsl:when>
					<xsl:when test="string-length(*[name()=concat($Pref,'CountryName')])>0 and contains('QWERTYUIOPLKJHGFDSAZXCVBNM',substring(*[name()=concat($Pref,'CountryName')],1,1))">
						<xsl:variable name="CrCI" select="*[name()=concat($Pref,'CountryName')]"/>
						<xsl:value-of select="$NsiPathFunc//Country_ITEM[EngName=$CrCI]/Code"/>
					</xsl:when>
				</xsl:choose>
			</xsl:element>
		</xsl:if>
		<xsl:choose>
			<xsl:when test="$PostalAddress=1">
				<xsl:call-template name="Address">
					<xsl:with-param name="Pref" select="$Pref"/>
					<xsl:with-param name="NodeName" select="'cat_ru:Address'"/>
					<xsl:with-param name="Namsp" select="$NameSp"/>
					<xsl:with-param name="NamspNode" select="$NamspNode"/>
				</xsl:call-template>
			</xsl:when>
			<xsl:when test="$PostalAddress=2">
				<xsl:call-template name="Address">
					<xsl:with-param name="Pref" select="$Pref"/>
					<xsl:with-param name="NodeName" select="'PostalAddress'"/>
					<xsl:with-param name="Namsp" select="$NameSp"/>
					<xsl:with-param name="NamspNode" select="$NamspNode"/>
				</xsl:call-template>
			</xsl:when>
			<xsl:when test="$PostalAddress=3">
				<xsl:call-template name="Address">
					<xsl:with-param name="Pref" select="$Pref"/>
					<xsl:with-param name="NodeName">Address</xsl:with-param>
					<xsl:with-param name="Namsp" select="$NameSp"/>
					<xsl:with-param name="NamspNode" select="$NamspNode"/>
					<xsl:with-param name="PrefResult" select="$PrefResult"/>
					<xsl:with-param name="PrefResultSp" select="$PrefResultSp"/>
				</xsl:call-template>
			</xsl:when>
			<xsl:when test="$PostalAddress=4">
				<xsl:call-template name="Address">
					<xsl:with-param name="Pref" select="$Pref"/>
					<xsl:with-param name="NodeName" select="'catWH_ru:Address'"/>
					<xsl:with-param name="Namsp" select="$NameSp"/>
					<xsl:with-param name="NamspNode" select="$NamspNodeAdr"/>
				</xsl:call-template>
			</xsl:when>
			<xsl:when test="$PostalAddress=5">
				<xsl:call-template name="Address">
					<xsl:with-param name="Pref" select="$Pref"/>
					<xsl:with-param name="NodeName" select="'catSert_ru:LegalAddress'"/>
					<xsl:with-param name="Namsp" select="$NameSp"/>
					<xsl:with-param name="NamspNode" select="$NamspNodeAdr"/>
				</xsl:call-template>
			</xsl:when>
			<xsl:when test="$PostalAddress=6">
				<xsl:call-template name="Address">
					<xsl:with-param name="Pref" select="$Pref"/>
					<xsl:with-param name="NodeName" select="'catWH_ru:Address'"/>
					<xsl:with-param name="Namsp" select="$NameSp"/>
					<xsl:with-param name="NamspNode" select="$NamspNodeAdr"/>
					<xsl:with-param name="NoAddressLine" select="true()"/>
				</xsl:call-template>
			</xsl:when>
		</xsl:choose>
		<xsl:choose>
			<xsl:when test="$WHOwner=1">
				<xsl:element name="catWH_ru:WarehouseLicense" namespace="{$NamspNode}">
					<xsl:element name="catWH_ru:CertificateKind" namespace="{$NamspNode}">lic_Licence</xsl:element>
					<xsl:element name="catWH_ru:CertificateNumber" namespace="{$NamspNode}">0</xsl:element>
				</xsl:element>
				<xsl:element name="catWH_ru:WarehousePerson" namespace="{$NamspNode}">
					<xsl:element name="cat_ru:PersonSurname" namespace="{$NameSp}">N</xsl:element>
					<xsl:element name="cat_ru:PersonName" namespace="{$NameSp}">N</xsl:element>
				</xsl:element>
			</xsl:when>
			<xsl:when test="$WHOwner=2">
				<xsl:element name="catWH_ru:WarehouseLicense" namespace="{$NamspNode}">
					<xsl:element name="catWH_ru:CertificateKind" namespace="{$NamspNode}">lic_Licence</xsl:element>
					<xsl:element name="catWH_ru:CertificateNumber" namespace="{$NamspNode}">
						<xsl:choose>
							<xsl:when test="string-length(WarehouseLicenceID)>0">
								<xsl:value-of select="WarehouseLicenceID"/>
							</xsl:when>
							<xsl:otherwise>0</xsl:otherwise>
						</xsl:choose>
					</xsl:element>
					<xsl:if test="string-length(WarehouseLicenceDate)>0">
						<xsl:element name="catWH_ru:CertificateDate" namespace="{$NamspNode}">
							<xsl:call-template name="TranslateDate">
								<xsl:with-param name="Dat" select="WarehouseLicenceDate"/>
							</xsl:call-template>
						</xsl:element>
					</xsl:if>
				</xsl:element>
				<xsl:element name="catWH_ru:WarehousePerson" namespace="{$NamspNode}">
					<xsl:element name="cat_ru:PersonSurname" namespace="{$NameSp}">N</xsl:element>
					<xsl:element name="cat_ru:PersonName" namespace="{$NameSp}">N</xsl:element>
				</xsl:element>
			</xsl:when>
		</xsl:choose>
	</xsl:template>
	
	<xsl:template name="OrgNodeRU">
		<xsl:param name="Pref"/>
		<xsl:param name="NameSp"/>
		<xsl:param name="NameNode"/>
		<xsl:param name="NamspParent"/>
		<xsl:param name="PostalAddress"/>
		<xsl:param name="PrefAdr"/>
		<xsl:param name="Ver"/>
		<xsl:param name="Okpo"/>
		<xsl:if test="string-length(*[name()=concat($Pref,'Name')])>0">
			<xsl:call-template name="GoodsDescrNew">
				<xsl:with-param name="DesGoods" select="normalize-space(*[name()=concat($Pref,'Name')])"/>
				<xsl:with-param name="NodeName" select="'RUScat_ru:OrganizationName'"/>
				<xsl:with-param name="Namsp" select="$NameNode"/>
				<xsl:with-param name="NameMes" select="false"/>
				<xsl:with-param name="LenDes" select="500"/>
			</xsl:call-template>
		</xsl:if>
		<xsl:if test="string-length(*[name()=concat($Pref,'ShortName')])>0">
			<xsl:element name="{'RUScat_ru:ShortName'}" namespace="{$NameNode}">
				<xsl:value-of select="*[name()=concat($Pref,'ShortName')]"/>
			</xsl:element>
		</xsl:if>
		<xsl:if test="string-length(*[name()=concat($Pref,'OrganizationLanguage')])>0">
			<xsl:element name="{'RUScat_ru:OrganizationLanguage'}" namespace="{$NameNode}">
				<xsl:value-of select="*[name()=concat($Pref,'OrganizationLanguage')]"/>
			</xsl:element>
		</xsl:if>
		<xsl:choose>
			<xsl:when test="(*[name()=concat($Pref,'CountryCode')]='RU') and (string-length(*[name()=concat($Pref,'OGRN')])>0 or string-length(*[name()=concat($Pref,'INN')])>0 or string-length(*[name()=concat($Pref,'KPP')])>0)">
				<xsl:element name="RUScat_ru:RFOrganizationFeatures" namespace="{$NameNode}">
					<xsl:if test="string-length(*[name()=concat($Pref,'OGRN')])>0">
						<xsl:element name="{'cat_ru:OGRN'}" namespace="{$NameSp}">
							<xsl:value-of select="*[name()=concat($Pref,'OGRN')]"/>
						</xsl:element>
					</xsl:if>
					<xsl:if test="string-length(*[name()=concat($Pref,'INN')])>0">
						<xsl:element name="{'cat_ru:INN'}" namespace="{$NameSp}">
							<xsl:value-of select="normalize-space(*[name()=concat($Pref,'INN')])"/>
						</xsl:element>
					</xsl:if>
					<xsl:if test="string-length(*[name()=concat($Pref,'KPP')])>0">
						<xsl:element name="{'cat_ru:KPP'}" namespace="{$NameSp}">
							<xsl:value-of select="*[name()=concat($Pref,'KPP')]"/>
						</xsl:element>
					</xsl:if>
				</xsl:element>
			</xsl:when>
			<xsl:when test="*[name()=concat($Pref,'CountryCode')]='BY' and string-length(*[name()=concat($Pref,'INN')])>0">
				<xsl:element name="RUScat_ru:RBOrganizationFeatures" namespace="{$NameNode}">
					<xsl:if test="string-length(*[name()=concat($Pref,'INN')])>0">
						<xsl:element name="{'cat_ru:UNP'}" namespace="{$NameSp}">
							<xsl:value-of select="*[name()=concat($Pref,'INN')]"/>
						</xsl:element>
					</xsl:if>
				</xsl:element>
			</xsl:when>
			<xsl:when test="*[name()=concat($Pref,'CountryCode')]='KZ' and (string-length(*[name()=concat($Pref,'OGRN')])>0 or string-length(*[name()=concat($Pref,'INN')])>0)">
				<xsl:element name="RUScat_ru:RKOrganizationFeatures" namespace="{$NameNode}">
					<xsl:if test="string-length(*[name()=concat($Pref,'OGRN')])>0">
						<xsl:element name="{'cat_ru:BIN'}" namespace="{$NameSp}">
							<xsl:value-of select="*[name()=concat($Pref,'OGRN')]"/>
						</xsl:element>
					</xsl:if>
					<xsl:if test="string-length(*[name()=concat($Pref,'INN')])>0">
						<xsl:element name="{'cat_ru:IIN'}" namespace="{$NameSp}">
							<xsl:value-of select="*[name()=concat($Pref,'INN')]"/>
						</xsl:element>
					</xsl:if>
				</xsl:element>
			</xsl:when>
			<xsl:when test="*[name()=concat($Pref,'CountryCode')]='AM' and string-length(*[name()=concat($Pref,'INN')])>0">
				<xsl:element name="RUScat_ru:RAOrganizationFeatures" namespace="{$NameNode}">
					<xsl:if test="string-length(*[name()=concat($Pref,'INN')])>0">
						<xsl:element name="{'cat_ru:UNN'}" namespace="{$NameSp}">
							<xsl:value-of select="*[name()=concat($Pref,'INN')]"/>
						</xsl:element>
					</xsl:if>
				</xsl:element>
			</xsl:when>
			<xsl:when test="*[name()=concat($Pref,'CountryCode')]='KG' and string-length(*[name()=concat($Pref,'INN')])>0">
				<xsl:element name="RUScat_ru:KGOrganizationFeatures" namespace="{$NameNode}">
					<xsl:if test="string-length(*[name()=concat($Pref,'INN')])>0">
						<xsl:element name="{'cat_ru:KGINN'}" namespace="{$NameSp}">
							<xsl:value-of select="*[name()=concat($Pref,'INN')]"/>
						</xsl:element>
					</xsl:if>
				</xsl:element>
			</xsl:when>
		</xsl:choose>
		<xsl:if test="string-length($Okpo)>0">
			<xsl:call-template name="OKPONode">
				<xsl:with-param name="Pref" select="$Pref"/>
				<xsl:with-param name="Namsp" select="$NameSp"/>
				<xsl:with-param name="Ver" select="$Ver"/>
			</xsl:call-template>	
		</xsl:if>
		<xsl:choose>
			<xsl:when test="$PostalAddress=1">
				<xsl:call-template name="Address">
					<xsl:with-param name="Pref" select="$Pref"/>
					<xsl:with-param name="NodeName">RUScat_ru:Address</xsl:with-param>
					<xsl:with-param name="Namsp" select="$NameSp"/>
					<xsl:with-param name="NamspNode" select="$NameNode"/>
				</xsl:call-template>
			</xsl:when>
			<xsl:when test="$PostalAddress=2">
				<xsl:call-template name="Address">
					<xsl:with-param name="Pref" select="$Pref"/>
					<xsl:with-param name="NodeName">RUScat_ru:Address</xsl:with-param>
					<xsl:with-param name="NamspNode" select="$NameNode"/>
					<xsl:with-param name="PrefResultSp" select="$NameNode"/>
					<xsl:with-param name="PrefResult" select="$PrefAdr"/>
					<xsl:with-param name="Ver" select="$Ver"/>
				</xsl:call-template>
			</xsl:when>
		</xsl:choose>
	</xsl:template>
	
	<xsl:template name="OrgId">
		<xsl:param name="Pref"/>
		<xsl:param name="PrefNode"/>
		<xsl:param name="NameSp"/>
		<xsl:param name="NodeSp"/>
		<xsl:choose>
			<xsl:when test="*[name()=concat($Pref,'CountryCode')]='RU' and (string-length(*[name()=concat($Pref,'OGRN')])>0 or string-length(*[name()=concat($Pref,'INN')])>0 or string-length(*[name()=concat($Pref,'KPP')])>0)">
				<xsl:element name="{concat($PrefNode,'RFOrganizationFeatures')}" namespace="{$NodeSp}">
					<xsl:if test="string-length(*[name()=concat($Pref,'OGRN')])>0">
						<xsl:element name="cat_ru:OGRN" namespace="{$NameSp}">
							<xsl:value-of select="*[name()=concat($Pref,'OGRN')]"/>
						</xsl:element>
					</xsl:if>
					<xsl:if test="string-length(*[name()=concat($Pref,'INN')])>0">
						<xsl:element name="cat_ru:INN" namespace="{$NameSp}">
							<xsl:value-of select="normalize-space(*[name()=concat($Pref,'INN')])"/>
						</xsl:element>
					</xsl:if>
					<xsl:if test="string-length(*[name()=concat($Pref,'KPP')])>0">
						<xsl:element name="cat_ru:KPP" namespace="{$NameSp}">
							<xsl:value-of select="*[name()=concat($Pref,'KPP')]"/>
						</xsl:element>
					</xsl:if>
				</xsl:element>
			</xsl:when>
			<xsl:when test="*[name()=concat($Pref,'CountryCode')]='BY' and string-length(*[name()=concat($Pref,'INN')])>0">
				<xsl:element name="{concat($PrefNode,'RBOrganizationFeatures')}" namespace="{$NodeSp}">
					<xsl:if test="string-length(*[name()=concat($Pref,'INN')])>0">
						<xsl:element name="cat_ru:UNP" namespace="{$NameSp}">
							<xsl:value-of select="substring(normalize-space(*[name()=concat($Pref,'INN')]),1,9)"/>
						</xsl:element>
					</xsl:if>
				</xsl:element>
			</xsl:when>
			<xsl:when test="*[name()=concat($Pref,'CountryCode')]='KZ' and (string-length(*[name()=concat($Pref,'OGRN')])>0 or string-length(*[name()=concat($Pref,'INN')])>0)">
				<xsl:element name="{concat($PrefNode,'RKOrganizationFeatures')}" namespace="{$NodeSp}">
					<xsl:if test="string-length(*[name()=concat($Pref,'OGRN')])>0">
						<xsl:element name="cat_ru:BIN" namespace="{$NameSp}">
							<xsl:value-of select="*[name()=concat($Pref,'OGRN')]"/>
						</xsl:element>
					</xsl:if>
					<xsl:if test="string-length(*[name()=concat($Pref,'INN')])>0">
						<xsl:element name="cat_ru:IIN" namespace="{$NameSp}">
							<xsl:value-of select="*[name()=concat($Pref,'INN')]"/>
						</xsl:element>
					</xsl:if>
				</xsl:element>
			</xsl:when>
			<xsl:when test="*[name()=concat($Pref,'CountryCode')]='AM' and string-length(*[name()=concat($Pref,'INN')])>0">
				<xsl:element name="{concat($PrefNode,'RAOrganizationFeatures')}" namespace="{$NodeSp}">
					<xsl:if test="string-length(*[name()=concat($Pref,'INN')])>0">
						<xsl:element name="cat_ru:UNN" namespace="{$NameSp}">
							<xsl:value-of select="substring(normalize-space(*[name()=concat($Pref,'INN')]),1,12)"/>
						</xsl:element>
					</xsl:if>
				</xsl:element>
			</xsl:when>
			<xsl:when test="*[name()=concat($Pref,'CountryCode')]='KG' and string-length(*[name()=concat($Pref,'INN')])>0">
				<xsl:element name="{concat($PrefNode,'KGOrganizationFeatures')}" namespace="{$NodeSp}">
					<xsl:if test="string-length(*[name()=concat($Pref,'INN')])>0">
						<xsl:element name="cat_ru:KGINN" namespace="{$NameSp}">
							<xsl:value-of select="substring(normalize-space(*[name()=concat($Pref,'INN')]),1,14)"/>
						</xsl:element>
					</xsl:if>
				</xsl:element>
			</xsl:when>
		</xsl:choose>	
	</xsl:template>
	
	<xsl:template name="DriverInformation">
		<xsl:param name="Namsp"/>
		<xsl:param name="Nodesp"/>
		<xsl:param name="NamspDoc"/>
		<xsl:param name="NodeCont"/>
		<xsl:param name="Pref"/>
		<xsl:param name="Doc"/>
		<xsl:param name="NotDoc"/>
		<xsl:param name="Now"/>
		<xsl:param name="PrefRez"/>
		<xsl:param name="VerAlb"/>
		<xsl:if test="string-length(*[name()=concat($Pref,'PersonSurname')])>0">
			<xsl:element name="cat_ru:PersonSurname" namespace="{$Namsp}">
				<xsl:value-of select="*[name()=concat($Pref,'PersonSurname')]"/>
			</xsl:element>
		</xsl:if>
		<xsl:if test="string-length(*[name()=concat($Pref,'PersonName')])>0">
			<xsl:element name="cat_ru:PersonName" namespace="{$Namsp}">
				<xsl:value-of select="*[name()=concat($Pref,'PersonName')]"/>
			</xsl:element>
		</xsl:if>
		<xsl:if test="string-length(*[name()=concat($Pref,'PersonMiddleName')])>0">
			<xsl:element name="cat_ru:PersonMiddleName" namespace="{$Namsp}">
				<xsl:value-of select="*[name()=concat($Pref,'PersonMiddleName')]"/>
			</xsl:element>
		</xsl:if>
		<xsl:if test="string-length(*[name()=concat($Pref,'PersonPost')])>0">
			<xsl:element name="cat_ru:PersonPost" namespace="{$Namsp}">
				<xsl:value-of select="*[name()=concat($Pref,'PersonPost')]"/>
			</xsl:element>
		</xsl:if>
		<xsl:if test="string-length(*[name()=concat($Pref,'CountryCode')])>0 and $Pref!='Filled_' and $Doc!='INV' and string-length($NotDoc)=0">
			<xsl:element name="cat_ru:RegCountryCode" namespace="{$Namsp}">
				<xsl:value-of select="*[name()=concat($Pref,'CountryCode')]"/>
			</xsl:element>
		</xsl:if>
		<xsl:choose>
			<xsl:when test="$Doc='INV'">
				<xsl:if test="(string-length(*[name()=concat($Pref,'IndentityCardCode')])>0 or string-length(*[name()=concat($Pref,'IdentityCardName')])>0 or string-length(*[name()=concat($Pref,'IdentityCardSeries')])>0 or string-length(*[name()=concat($Pref,'IdentityCardNumder')])>0 or string-length(*[name()=concat($Pref,'IdentityCardNumber')])>0 or string-length(*[name()=concat($Pref,'IndentityCardDate')])>0 or string-length(*[name()=concat($Pref,'RBIdentificationNumber')])>0 or string-length(*[name()=concat($Pref,'OrganizationName')])>0)">
					<xsl:call-template name="IdentityCard">
						<xsl:with-param name="NodeName">IdentityCard</xsl:with-param>
						<xsl:with-param name="Namsp">
							<xsl:choose>
								<xsl:when test="string-length($NamspDoc)>0">
									<xsl:value-of select="$NamspDoc"/>
								</xsl:when>
								<xsl:otherwise>
									<xsl:value-of select="$Namsp"/>
								</xsl:otherwise>
							</xsl:choose>
						</xsl:with-param>
						<xsl:with-param name="NamspNode" select="$Nodesp"/>
						<xsl:with-param name="Pref" select="$Pref"/>
						<xsl:with-param name="PrefRez" select="$PrefRez"/>
					</xsl:call-template>
				</xsl:if>
			</xsl:when>
			<xsl:when test="string-length($NotDoc)=0">
				<xsl:call-template name="IdentityCard">
					<xsl:with-param name="NodeName">cat_ru:IdentityCard</xsl:with-param>
					<xsl:with-param name="Namsp" select="$Namsp"/>
					<xsl:with-param name="NamspNode" select="$Namsp"/>
					<xsl:with-param name="Pref" select="$Pref"/>
				</xsl:call-template>
			</xsl:when>
		</xsl:choose>
	</xsl:template>

	<xsl:template name="IdentityCardNode">
		<xsl:param name="Namsp"/>
		<xsl:param name="Pref"/>
		<xsl:param name="PrefN"/>
		<xsl:if test="string-length(*[name()=concat($Pref,'IndentityCardCode')])>0">
			<xsl:element name="{concat($PrefN,'IdentityCardCode')}" namespace="{$Namsp}">
				<xsl:value-of select="*[name()=concat($Pref,'IndentityCardCode')]"/>
			</xsl:element>
		</xsl:if>
		<xsl:if test="string-length(*[name()=concat($Pref,'IdentityCardCode')])>0">
			<xsl:element name="{concat($PrefN,'IdentityCardCode')}" namespace="{$Namsp}">
				<xsl:value-of select="*[name()=concat($Pref,'IdentityCardCode')]"/>
			</xsl:element>
		</xsl:if>
		<xsl:if test="string-length(*[name()=concat($Pref,'IdentityCardName')])>0">
			<xsl:element name="{concat($PrefN,'IdentityCardName')}" namespace="{$Namsp}">
				<xsl:value-of select="substring(*[name()=concat($Pref,'IdentityCardName')],1,40)"/>
			</xsl:element>
		</xsl:if>
		<xsl:if test="string-length(*[name()=concat($Pref,'FullIdentityCardName')])>0">
			<xsl:element name="{concat($PrefN,'FullIdentityCardName')}" namespace="{$Namsp}">
				<xsl:value-of select="*[name()=concat($Pref,'FullIdentityCardName')]"/>
			</xsl:element>
		</xsl:if>
		<xsl:if test="string-length(*[name()=concat($Pref,'IdentityCardSeries')])>0">
			<xsl:element name="{concat($PrefN,'IdentityCardSeries')}" namespace="{$Namsp}">
				<xsl:value-of select="*[name()=concat($Pref,'IdentityCardSeries')]"/>
			</xsl:element>
		</xsl:if>
		<xsl:if test="string-length(*[name()=concat($Pref,'IdentityCardNumder')])>0">
			<xsl:element name="{concat($PrefN,'IdentityCardNumber')}" namespace="{$Namsp}">
				<xsl:choose>
					<xsl:when test="string-length(*[name()=concat($Pref,'IdentityCardNumder')])>25">
						<xsl:value-of select="substring(*[name()=concat($Pref,'IdentityCardNumder')],1,25)"/>
					</xsl:when>
					<xsl:otherwise>
						<xsl:value-of select="*[name()=concat($Pref,'IdentityCardNumder')]"/>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:element>
		</xsl:if>
		<xsl:if test="string-length(*[name()=concat($Pref,'IdentityCardNumber')])>0">
			<xsl:element name="{concat($PrefN,'IdentityCardNumber')}" namespace="{$Namsp}">
				<xsl:choose>
					<xsl:when test="string-length(*[name()=concat($Pref,'IdentityCardNumber')])>25">
						<xsl:value-of select="substring(*[name()=concat($Pref,'IdentityCardNumber')],1,25)"/>
					</xsl:when>
					<xsl:otherwise>
						<xsl:value-of select="*[name()=concat($Pref,'IdentityCardNumber')]"/>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:element>
		</xsl:if>
		<xsl:if test="string-length(*[name()=concat($Pref,'IndentityCardDate')])>0">
			<xsl:element name="{concat($PrefN,'IdentityCardDate')}" namespace="{$Namsp}">
				<xsl:call-template name="TranslateDate">
					<xsl:with-param name="Dat" select="*[name()=concat($Pref,'IndentityCardDate')]"/>
				</xsl:call-template>
			</xsl:element>
		</xsl:if>
		<xsl:if test="string-length(*[name()=concat($Pref,'IdentityCardDate')])>0">
			<xsl:element name="{concat($PrefN,'IdentityCardDate')}" namespace="{$Namsp}">
				<xsl:call-template name="TranslateDate">
					<xsl:with-param name="Dat" select="*[name()=concat($Pref,'IdentityCardDate')]"/>
				</xsl:call-template>
			</xsl:element>
		</xsl:if>
		<xsl:if test="string-length(*[name()=concat($Pref,'DocValidityDate')])>0">
			<xsl:element name="{concat($PrefN,'DocValidityDate')}" namespace="{$Namsp}">
				<xsl:call-template name="TranslateDate">
					<xsl:with-param name="Dat" select="*[name()=concat($Pref,'DocValidityDate')]"/>
				</xsl:call-template>
			</xsl:element>
		</xsl:if>

		<xsl:if test="string-length(*[name()=concat($Pref,'RBIdentificationNumber')])>0">
			<xsl:element name="{concat($PrefN,'RBIdentificationNumber')}" namespace="{$Namsp}">
				<xsl:value-of select="*[name()=concat($Pref,'RBIdentificationNumber')]"/>
			</xsl:element>
		</xsl:if>
		<xsl:if test="string-length(*[name()=concat($Pref,'OrganizationName')])>0">
			<xsl:element name="{concat($PrefN,'OrganizationName')}" namespace="{$Namsp}">
				<xsl:value-of select="*[name()=concat($Pref,'OrganizationName')]"/>
			</xsl:element>
		</xsl:if>
		<xsl:if test="string-length(*[name()=concat($Pref,'IdentityCardOrgName')])>0">
			<xsl:element name="{concat($PrefN,'OrganizationName')}" namespace="{$Namsp}">
				<xsl:value-of select="*[name()=concat($Pref,'IdentityCardOrgName')]"/>
			</xsl:element>
		</xsl:if>
		<xsl:if test="string-length(*[name()=concat($Pref,'IssuerCode')])>0">
			<xsl:element name="{concat($PrefN,'IssuerCode')}" namespace="{$Namsp}">
				<xsl:value-of select="*[name()=concat($Pref,'IssuerCode')]"/>
			</xsl:element>
		</xsl:if>
		<xsl:if test="string-length(*[name()=concat($Pref,'AuthorityId')])>0">
			<xsl:element name="{concat($PrefN,'AuthorityId')}" namespace="{$Namsp}">
				<xsl:value-of select="*[name()=concat($Pref,'AuthorityId')]"/>
			</xsl:element>
		</xsl:if>
		<xsl:if test="string-length(*[name()=concat($Pref,'IndentityCountryCode')])>0">
			<xsl:element name="{concat($PrefN,'CountryCode')}" namespace="{$Namsp}">
				<xsl:value-of select="*[name()=concat($Pref,'IndentityCountryCode')]"/>
			</xsl:element>
		</xsl:if>
		<xsl:if test="string-length(*[name()=concat($Pref,'IdentityCountryCode')])>0">
			<xsl:element name="{concat($PrefN,'CountryCode')}" namespace="{$Namsp}">
				<xsl:value-of select="*[name()=concat($Pref,'IdentityCountryCode')]"/>
			</xsl:element>
		</xsl:if>
	</xsl:template>
	
	<xsl:template name="IdentityCard">
		<xsl:param name="NodeName"/>
		<xsl:param name="Namsp"/>
		<xsl:param name="NamspNode"/>
		<xsl:param name="Pref"/>
		<xsl:param name="PrefRez"/>
		<xsl:variable name="PrefN">
			<xsl:choose>
				<xsl:when test="string-length($PrefRez)=0">cat_ru:</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="$PrefRez"/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<xsl:element name="{$NodeName}" namespace="{$NamspNode}">
			<xsl:call-template name="IdentityCardNode">
				<xsl:with-param name="Namsp" select="$Namsp"/>
				<xsl:with-param name="Pref" select="$Pref"/>
				<xsl:with-param name="PrefN" select="$PrefN"/>
			</xsl:call-template>
		</xsl:element>
	</xsl:template>

	<xsl:template name="OKPONode">
		<xsl:param name="Namsp"/>
		<xsl:param name="NamspNode"/>
		<xsl:param name="Pref"/>
		<xsl:param name="Ver"/>
		<xsl:variable name="PrefN">cat_ru:</xsl:variable>
		<xsl:variable name="NameSp1">
			<xsl:choose>
				<xsl:when test="string-length($PrefN)>0">
					<xsl:value-of select="$Namsp"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="$NamspNode"/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<xsl:choose>
			<xsl:when test="(string-length(*[name()=concat($Pref,'OKPO')])=10  or string-length(*[name()=concat($Pref,'OKPO')])=8) and *[name()=concat($Pref,'OKPO')]!='0000'">
				<xsl:element name="{concat($PrefN,'OKPOID')}" namespace="{$NameSp1}">
					<xsl:value-of select="*[name()=concat($Pref,'OKPO')]"/>
				</xsl:element>
			</xsl:when>
			<xsl:when test="(string-length(*[name()=concat($Pref,'OKPOID')])=10 or string-length(*[name()=concat($Pref,'OKPOID')])=8) and *[name()=concat($Pref,'OKPOID')]!='0000'">
				<xsl:element name="{concat($PrefN,'OKPOID')}" namespace="{$NameSp1}">
					<xsl:value-of select="*[name()=concat($Pref,'OKPOID')]"/>
				</xsl:element>
			</xsl:when>
		</xsl:choose>
		<xsl:if test="string-length(*[name()=concat($Pref,'OKATOCode')])>0">
			<xsl:element name="{concat($PrefN,'OKATOCode')}" namespace="{$NameSp1}">
				<xsl:value-of select="*[name()=concat($Pref,'OKATOCode')]"/>
			</xsl:element>
		</xsl:if>
		<xsl:if test="string-length(*[name()=concat($Pref,'OKATO')])>0 and number($Ver)>5142">
			<xsl:element name="{concat($PrefN,'OKATOCode')}" namespace="{$NameSp1}">
				<xsl:value-of select="*[name()=concat($Pref,'OKATO')]"/>
			</xsl:element>
		</xsl:if>
	</xsl:template>
	
	<xsl:template name="ContactNode">
		<xsl:param name="Namsp"/>
		<xsl:param name="Pref"/>
		<xsl:param name="PrefNode"/>
		<xsl:param name="Email"/>
		<xsl:variable name="name-email">
			<xsl:choose>
				<xsl:when test="string-length($Email)>0">
					<xsl:value-of select="$Email"/>
				</xsl:when>
				<xsl:otherwise>E_mail</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<xsl:if test="string-length(*[name()=concat($Pref,'Phone')])>0">
			<xsl:call-template name="GoodsDescrNew">
				<xsl:with-param name="DesGoods" select="*[name()=concat($Pref,'Phone')]"/>
				<xsl:with-param name="NodeName" select="concat($PrefNode,'Phone')"/>
				<xsl:with-param name="Namsp" select="$Namsp"/>
				<xsl:with-param name="NameMes" select="true"/>
				<xsl:with-param name="LenDes" select="24"/>
			</xsl:call-template>
		</xsl:if>
		<xsl:if test="string-length(*[name()=concat($Pref,'Email')])>0">
			<xsl:call-template name="GoodsDescrNew">
				<xsl:with-param name="DesGoods" select="*[name()=concat($Pref,'Email')]"/>
				<xsl:with-param name="NodeName" select="concat($PrefNode,$name-email)"/>
				<xsl:with-param name="Namsp" select="$Namsp"/>
				<xsl:with-param name="NameMes" select="true"/>
				<xsl:with-param name="LenDes" select="50"/>
			</xsl:call-template>
		</xsl:if>
	</xsl:template>

	<xsl:template name="Contact">
		<xsl:param name="NodeName"/>
		<xsl:param name="Namsp"/>
		<xsl:param name="NamspNode"/>
		<xsl:param name="Pref"/>
		<xsl:param name="PrefNode"/>
		<xsl:if test="string-length(*[name()=concat($Pref,'Phone')])>0 or string-length(*[name()=concat($Pref,'Email')])>0">
			<xsl:element name="{$NodeName}" namespace="{$NamspNode}">
				<xsl:call-template name="ContactNode">
					<xsl:with-param name="Namsp" select="$Namsp"/>
					<xsl:with-param name="Pref" select="$Pref"/>
					<xsl:with-param name="PrefNode">
						<xsl:choose>
							<xsl:when test="string-length($PrefNode)>0">
								<xsl:value-of select="$PrefNode"/>
							</xsl:when>
							<xsl:otherwise>cat_ru:</xsl:otherwise>
						</xsl:choose>
					</xsl:with-param>
				</xsl:call-template>
			</xsl:element>
		</xsl:if>
	</xsl:template>

	<xsl:template name="replace">
		<xsl:param name="ptext"/>
		<xsl:param name="ppattern"/>
		<xsl:param name="preplacement"/>
		<xsl:choose>
			<xsl:when test="not(contains($ptext, $ppattern))">
				<xsl:value-of select="$ptext"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="substring-before($ptext, $ppattern)"/>
				<xsl:value-of select="$preplacement"/>
				<xsl:call-template name="replace">
					<xsl:with-param name="ptext" select="substring-after($ptext, $ppattern)"/>
					<xsl:with-param name="ppattern" select="$ppattern"/>
					<xsl:with-param name="preplacement" select="$preplacement"/>
				</xsl:call-template>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template name="GoodsDescrNew250">
		<xsl:param name="DesG"/>
		<xsl:param name="NodeName"/>
		<xsl:param name="Namsp"/>
		<xsl:param name="LenDes"/>
		<xsl:variable name="FirstText" select="substring($DesG,1,$LenDes)"/>
		<xsl:if test="string-length($FirstText)>0">
			<xsl:element name="{$NodeName}" namespace="{$Namsp}">
				<xsl:value-of select="$FirstText"/>
			</xsl:element>
		</xsl:if>
		<xsl:variable name="LastText" select="substring($DesG,string-length($FirstText)+1)"/>
		<xsl:if test="string-length($LastText)>0">
			<xsl:call-template name="GoodsDescrNew250">
				<xsl:with-param name="DesG" select="$LastText"/>
				<xsl:with-param name="NodeName" select="$NodeName"/>
				<xsl:with-param name="Namsp" select="$Namsp"/>
				<xsl:with-param name="LenDes" select="$LenDes"/>
			</xsl:call-template>
		</xsl:if>
	</xsl:template>	
	
	<xsl:template name="GoodsDescrNew">
		<xsl:param name="DesGoods"/>
		<xsl:param name="NodeName"/>
		<xsl:param name="Namsp"/>
		<xsl:param name="NameMes"/>
		<xsl:param name="NotNormalize"/>
		<xsl:param name="LenDes"/>
		<xsl:choose>
			<xsl:when test="string-length($DesGoods)>0">
				<xsl:choose>
					<xsl:when test="string-length($DesGoods)>$LenDes">
						<xsl:call-template name="GoodsDescrNew250">
							<xsl:with-param name="DesG">
								<xsl:choose>
									<xsl:when test="string-length($NotNormalize)>0">
										<xsl:value-of  select="$DesGoods"/>
									</xsl:when>
									<xsl:otherwise>
										<xsl:value-of  select="normalize-space($DesGoods)"/>
									</xsl:otherwise>
								</xsl:choose>
							</xsl:with-param>
							<xsl:with-param name="NodeName" select="$NodeName"/>
							<xsl:with-param name="Namsp" select="$Namsp"/>
							<xsl:with-param name="LenDes" select="$LenDes"/>
						</xsl:call-template>
					</xsl:when>
					<xsl:otherwise>
						<xsl:element name="{$NodeName}" namespace="{$Namsp}">
							<xsl:choose>
								<xsl:when test="string-length($NotNormalize)>0">
									<xsl:value-of  select="$DesGoods"/>
								</xsl:when>
								<xsl:otherwise>
									<xsl:value-of  select="normalize-space($DesGoods)"/>
								</xsl:otherwise>
							</xsl:choose>
						</xsl:element>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:when>
			<xsl:otherwise>
				<xsl:choose>
					<xsl:when test="boolean($NameMes)">
						<xsl:message terminate="yes">поле "Наименование груза" не заполнено</xsl:message>
					</xsl:when>
					<xsl:when test="string-length($NameMes)=0"/>
					<xsl:otherwise>
						<xsl:element name="{$NodeName}" namespace="{$Namsp}">N</xsl:element>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template name="TranslateDate">
		<xsl:param name="Dat"/>
		<xsl:variable name="Dat10" select="normalize-space(substring($Dat,1,10))"/>
		<xsl:choose>
			<xsl:when test="contains($Dat10,'.')">
				<xsl:value-of select="concat(substring($Dat10,7,4),'-',substring($Dat10,4,2),'-',substring($Dat10,1,2))"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="$Dat10"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template name="tokenize">
		<xsl:param name="string" select="''"/>
		<xsl:param name="NodeName"/>
		<xsl:param name="Nodespace"/>
		<xsl:param name="NameN"/>
		<xsl:param name="NameNsp"/>
		<xsl:param name="delimiters" select="' &#x9;&#xA;'"/>
		<xsl:choose>
			<xsl:when test="not($string)"/>
			<xsl:when test="not($delimiters)">
				<xsl:call-template name="_tokenize-characters">
					<xsl:with-param name="string" select="$string"/>
				</xsl:call-template>
			</xsl:when>
			<xsl:otherwise>
				<xsl:call-template name="_tokenize-delimiters">
					<xsl:with-param name="string" select="$string"/>
					<xsl:with-param name="delimiters" select="$delimiters"/>
					<xsl:with-param name="NodeName" select="$NodeName"/>
					<xsl:with-param name="Nodespace" select="$Nodespace"/>
					<xsl:with-param name="NameN" select="$NameN"/>
					<xsl:with-param name="NameNsp" select="$NameNsp"/>
				</xsl:call-template>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	<xsl:template name="_tokenize-characters">
		<xsl:param name="string"/>
		<xsl:param name="NodeName"/>
		<xsl:param name="Nodespace"/>
		<xsl:param name="NameN"/>
		<xsl:param name="NameNsp"/>
		<xsl:if test="$string">
			<node>
				<xsl:value-of select="normalize-space(substring($string, 1, 1))"/>
			</node>
			<xsl:call-template name="_tokenize-characters">
				<xsl:with-param name="string" select="substring($string, 2)"/>
			</xsl:call-template>
		</xsl:if>
	</xsl:template>
	<xsl:template name="_tokenize-delimiters">
		<xsl:param name="string"/>
		<xsl:param name="delimiters"/>
		<xsl:param name="NodeName"/>
		<xsl:param name="Nodespace"/>
		<xsl:param name="NameN"/>
		<xsl:param name="NameNsp"/>
		<xsl:variable name="delimiter" select="substring($delimiters, 1, 1)"/>
		<xsl:choose>
			<xsl:when test="not($delimiter)">
				<xsl:choose>
					<xsl:when test="string-length($NameN)>0">
						<xsl:element name="{$NameN}" namespace="{$NameNsp}">
							<xsl:element name="{$NodeName}" namespace="{$Nodespace}">
								<xsl:value-of select="normalize-space($string)"/>
							</xsl:element>
						</xsl:element>
					</xsl:when>
					<xsl:otherwise>
						<xsl:if  test="string-length(normalize-space($string))>0">
							<xsl:element name="{$NodeName}" namespace="{$Nodespace}">
								<xsl:value-of select="normalize-space($string)"/>
							</xsl:element>
						</xsl:if>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:when>
			<xsl:when test="contains($string, $delimiter)">
				<xsl:if test="not(starts-with($string, $delimiter))">
					<xsl:call-template name="_tokenize-delimiters">
						<xsl:with-param name="string" select="substring-before($string, $delimiter)"/>
						<xsl:with-param name="delimiters" select="substring($delimiters, 2)"/>
						<xsl:with-param name="NodeName" select="$NodeName"/>
						<xsl:with-param name="Nodespace" select="$Nodespace"/>
						<xsl:with-param name="NameN" select="$NameN"/>
						<xsl:with-param name="NameNsp" select="$NameNsp"/>
					</xsl:call-template>
				</xsl:if>
				<xsl:call-template name="_tokenize-delimiters">
					<xsl:with-param name="string" select="substring-after($string, $delimiter)"/>
					<xsl:with-param name="delimiters" select="$delimiters"/>
					<xsl:with-param name="NodeName" select="$NodeName"/>
					<xsl:with-param name="Nodespace" select="$Nodespace"/>
					<xsl:with-param name="NameN" select="$NameN"/>
					<xsl:with-param name="NameNsp" select="$NameNsp"/>
				</xsl:call-template>
			</xsl:when>
			<xsl:otherwise>
				<xsl:call-template name="_tokenize-delimiters">
					<xsl:with-param name="string" select="$string"/>
					<xsl:with-param name="delimiters" select="substring($delimiters, 2)"/>
					<xsl:with-param name="NodeName" select="$NodeName"/>
					<xsl:with-param name="Nodespace" select="$Nodespace"/>
					<xsl:with-param name="NameN" select="$NameN"/>
					<xsl:with-param name="NameNsp" select="$NameNsp"/>
				</xsl:call-template>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	
	<xsl:template name="PrDocument">
		<xsl:param name="NamDoc"/>
		<xsl:param name="NumDoc"/>
		<xsl:param name="DateDoc"/>
		<xsl:param name="Namsp"/>
		<xsl:if test="string-length($NamDoc)>0">
			<xsl:element name="cat_ru:PrDocumentName" namespace="{$Namsp}">
				<xsl:value-of select="$NamDoc"/>
			</xsl:element>
		</xsl:if>
		<xsl:if test="string-length($NumDoc)>0">
			<xsl:element name="cat_ru:PrDocumentNumber" namespace="{$Namsp}">
				<xsl:value-of select="$NumDoc"/>
			</xsl:element>
		</xsl:if>
		<xsl:if test="string-length($DateDoc)>0">
			<xsl:element name="cat_ru:PrDocumentDate" namespace="{$Namsp}">
				<xsl:call-template name="TranslateDate">
					<xsl:with-param name="Dat" select="$DateDoc"/>
				</xsl:call-template>
			</xsl:element>
		</xsl:if>
	</xsl:template>
	
	<xsl:template name="UpperCase">
		<xsl:param name="string"/>
		<xsl:variable name="engs" select="translate($string, $smallcaseeng, $uppercaseeng)"/>
		<xsl:value-of select="translate($engs, $smallcaserus, $uppercaserus)"/>
	</xsl:template>
	<xsl:template name="LowerCase">
		<xsl:param name="string"/>
		<xsl:variable name="engs" select="translate($string, $uppercaseeng, $smallcaseeng)"/>
		<xsl:value-of select="translate($engs, $uppercaserus, $smallcaserus)"/>
	</xsl:template>
	<xsl:template name="UpperCaseEng">
		<xsl:param name="string"/>
		<xsl:value-of select="translate($string, $smallcaseeng, $uppercaseeng)"/>
	</xsl:template>
	<xsl:template name="LowerCaseEng">
		<xsl:param name="string"/>
		<xsl:value-of select="translate($string, $uppercaseeng, $smallcaseeng)"/>
	</xsl:template>
	<xsl:template name="UpperCaseRus">
		<xsl:param name="string"/>
		<xsl:value-of select="translate($string, $smallcaserus, $uppercaserus)"/>
	</xsl:template>
	<xsl:template name="LowerCaseRus">
		<xsl:param name="string"/>
		<xsl:value-of select="translate($string, $uppercaserus, $smallcaserus)"/>
	</xsl:template>

	<xsl:template name="SimbolUpStr">
		<xsl:param name="Simb"/>
		<xsl:variable name="uppercase" select="'ЙЦУКЕНГШЩЗХЪЁФЫВАПРОЛДЖЭЯЧСМИТЬБЮ'"/>
		<xsl:value-of select="contains($uppercase,$Simb)"/>
	</xsl:template>
	<xsl:template name="SimbolUpNum">
		<xsl:param name="Simb"/>
		<xsl:variable name="uppercase" select="'1234567890'"/>
		<xsl:value-of select="contains($uppercase,$Simb)"/>
	</xsl:template>
	
	<xsl:template name="CustomsCountryCode">
		<xsl:param name="NameSp"/>
		<xsl:param name="CodTo"/>
		<xsl:param name="Pref"/>
		<xsl:variable name="NameNode">
			<xsl:choose>
				<xsl:when test="$Pref=1">CustomsCountryCode</xsl:when>
				<xsl:otherwise>cat_ru:CustomsCountryCode</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<xsl:element name="{$NameNode}" namespace="{$NameSp}">
			<xsl:choose>
				<xsl:when test="substring($CodTo,1,2)='10' or substring($CodTo,1,2)='12' or substring($CodTo,1,2)='1F'">643</xsl:when>
				<xsl:when test="substring($CodTo,1,3)='112' or substring($CodTo,1,3)='240'">112</xsl:when>
				<xsl:when test="substring($CodTo,1,3)='398'">398</xsl:when>
				<xsl:when test="substring($CodTo,1,2)='46' or substring($CodTo,1,3)='417'">417</xsl:when>
			</xsl:choose>
		</xsl:element>
	</xsl:template>
	<xsl:template name="PersonNode">
		<xsl:param name="PersonSurname"/>
		<xsl:param name="PersonName"/>
		<xsl:param name="PersonMiddle"/>
		<xsl:param name="PersonPost"/>
		<xsl:param name="Namsp"/>
		<xsl:param name="Pref"/>
		<xsl:if test="string-length($PersonSurname)>0">
			<xsl:element name="{concat($Pref,'PersonSurname')}" namespace="{$Namsp}">
				<xsl:value-of select="$PersonSurname"/>
			</xsl:element>
		</xsl:if>
		<xsl:if test="string-length($PersonName)>0">	
			<xsl:element name="{concat($Pref,'PersonName')}" namespace="{$Namsp}">
				<xsl:value-of select="$PersonName"/>
			</xsl:element>
		</xsl:if>	
		<xsl:if test="string-length($PersonMiddle)>0">
			<xsl:element name="{concat($Pref,'PersonMiddleName')}" namespace="{$Namsp}">
				<xsl:value-of select="$PersonMiddle"/>
			</xsl:element>
		</xsl:if>
		<xsl:if test="string-length($PersonPost)>0">
			<xsl:element name="{concat($Pref,'PersonPost')}" namespace="{$Namsp}">
				<xsl:value-of select="$PersonPost"/>
			</xsl:element>
		</xsl:if>
	</xsl:template>

	<xsl:template name="FormatGrossWeigth">
		<xsl:param name="ValGr"/>
		<xsl:variable name="IntVal">
			<xsl:choose>
				<xsl:when test="contains($ValGr,'.')">
					<xsl:value-of select="substring-before($ValGr,'.')"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="$ValGr"/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<xsl:variable name="fractVal">
			<xsl:choose>
				<xsl:when test="contains($ValGr,'.')">
					<xsl:value-of select="substring-after($ValGr,'.')"/>
				</xsl:when>
				<xsl:otherwise></xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<xsl:variable name="LenfractVal" select="string-length(normalize-space($fractVal))"/>
		<xsl:variable name="ResfractVal">
			<xsl:choose>
				<xsl:when test="$LenfractVal>0">
					<xsl:choose>
						<xsl:when test="$LenfractVal>3">
							<xsl:value-of select="format-number(concat('0.',normalize-space($fractVal),'000000'),'0.000000')"/>
						</xsl:when>
						<xsl:otherwise>
							<xsl:value-of select="format-number(concat('0.',normalize-space($fractVal),'000'),'0.000')"/>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:when>
				<xsl:otherwise>0.000</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<xsl:value-of select="concat($IntVal,'.',substring-after($ResfractVal,'.'))"/> 
	</xsl:template>

	<xsl:variable name="PalletCode">AH,AG,AF,PX,PD,PE,PB,BN,BX,PK,CK,SW,BG,PA,3H,1F,CS,CR,TS,ZZ,</xsl:variable>
	<xsl:variable name="PalletCodeInd">AH,AG,AF,PX,PD,PE,PB,ZZ,</xsl:variable>
	<xsl:variable name="PackCode">BX,PK,CK,SW,BG,PA,3H,1F,CS,CR,TS,</xsl:variable>
	<xsl:variable name="CargoCode">NF,NG,</xsl:variable>
	<xsl:variable name="NotPackCode">NE,NA,VR,VS,VY,VQ,VL,VG,VO,</xsl:variable>

	<xsl:template  name="PkgTypeCode">
		<xsl:param name="PlCode"/>
		<xsl:choose>
			<xsl:when test="contains($CargoCode,concat($PlCode,','))">2</xsl:when>
			<xsl:when test="contains($PalletCode,concat($PlCode,','))">1</xsl:when>
			<xsl:when test="contains($NotPackCode,concat($PlCode,','))">0</xsl:when>
			<xsl:otherwise>1</xsl:otherwise>	
		</xsl:choose>
	</xsl:template>

	<xsl:template name="InfoKindPack">
		<xsl:param name="PlCode"/>
		<xsl:choose>
			<xsl:when test="contains($NotPackCode,concat($PlCode,',')) or contains($PackCode,concat($PlCode,','))">0</xsl:when>
			<xsl:when test="contains($PalletCodeInd,concat($PlCode,','))">0</xsl:when>
			<xsl:when test="contains($CargoCode,concat($PlCode,','))">2</xsl:when>
			<xsl:otherwise>0</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	
	<xsl:template name="DataAndTime">
		<xsl:param name="s_date"/>
		<xsl:param name="s_time"/>
		<xsl:variable name="ArrivalDate">
			<xsl:call-template name="TranslateDate">
				<xsl:with-param name="Dat" select="$s_date"/>
			</xsl:call-template>
		</xsl:variable>		
		<xsl:variable name="ArrivalTime">
			<xsl:call-template name="TranslateTime">
				<xsl:with-param name="Time" select="$s_time"/>
			</xsl:call-template>
		</xsl:variable>
		<xsl:value-of select="normalize-space(concat(normalize-space($ArrivalDate),'T',normalize-space($ArrivalTime)))"/>		
	</xsl:template>
	
	<xsl:template name="TranslateTime">
		<xsl:param name="Time"/>
		<xsl:variable name="nTime">
			<xsl:choose>
				<xsl:when test="contains($Time,':') and not(contains($Time,'+')) and not(contains($Time,'-'))">
					<xsl:value-of select="normalize-space($Time)"/>
				</xsl:when>
				<xsl:when test="contains($Time,'+') or contains($Time,'-')">
					<xsl:value-of select="normalize-space(translate(translate($Time,'+',''),'-',':'))"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="normalize-space($Time)"/>
				</xsl:otherwise>
			</xsl:choose>	
		</xsl:variable> 
		<xsl:choose>
			<xsl:when test="string-length($nTime)=0">00:00:00</xsl:when>
			<xsl:when test="string-length($nTime)>0">
				<xsl:call-template name="ResTanslateTime">
					<xsl:with-param name="Time" select="$nTime"/>
				</xsl:call-template>
			</xsl:when>
		</xsl:choose>
	</xsl:template>
	<xsl:template name="ResTanslateTime">
		<xsl:param name="Time"/>
		<xsl:param name="rTime"/>
		<xsl:variable name="nTime">
			<xsl:choose>
				<xsl:when test="string-length($Time)>2 and contains($Time,':')">
					<xsl:value-of select="substring-before(normalize-space($Time),':')"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="normalize-space($Time)"/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>	
		<xsl:variable name="n1Time">
			<xsl:choose>
				<xsl:when test="string-length($nTime)=2">
					<xsl:value-of select="$nTime"/>
				</xsl:when>
				<xsl:when test="string-length($nTime)>2">
					<xsl:value-of select="substring($nTime,1,2)"/>
				</xsl:when>
				<xsl:when test="string-length($nTime)=1">
					0<xsl:value-of select="$nTime"/>
				</xsl:when>
				<xsl:when test="string-length($nTime)=0">00</xsl:when>
			</xsl:choose>
		</xsl:variable>
		
		<xsl:variable name="n2Time" select="substring-after(normalize-space($Time),':')"/>
		<xsl:choose>
			<xsl:when test="string-length($n2Time)>0 or string-length($rTime)&lt;6">
				<xsl:call-template name="ResTanslateTime">
					<xsl:with-param name="Time" select="$n2Time"/>
					<xsl:with-param name="rTime" select="concat($rTime,$n1Time,':')"/>
				</xsl:call-template>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="concat($rTime,$n1Time)"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	<xsl:template name="SealsNodeForConosament">
		<xsl:param name="NameSl"/>
		<xsl:param name="NameSp"/>
		<xsl:param name="NameNode"/>
		<xsl:param name="LenDes"/>
		<xsl:choose>
			<xsl:when test="string-length(*[name()=$NameSl])>number($LenDes) and contains(*[name()=$NameSl],',')">
				<xsl:call-template name="tokenize">
					<xsl:with-param name="string" select="normalize-space(*[name()=$NameSl])"/>		
					<xsl:with-param name="NodeName" select="$NameNode"/>
					<xsl:with-param name="Nodespace" select="$NameSp"/>
					<xsl:with-param name="delimiters">,</xsl:with-param>
				</xsl:call-template>
			</xsl:when>
			<xsl:when test="string-length(*[name()=$NameSl])>number($LenDes) and contains(*[name()=$NameSl],';')">
				<xsl:call-template name="tokenize">
					<xsl:with-param name="string" select="normalize-space(*[name()=$NameSl])"/>		
					<xsl:with-param name="NodeName" select="$NameNode"/>
					<xsl:with-param name="Nodespace" select="$NameSp"/>
					<xsl:with-param name="delimiters">;</xsl:with-param>
				</xsl:call-template>
			</xsl:when>
			<xsl:when test="string-length(*[name()=$NameSl])>number($LenDes) and not(contains(*[name()=$NameSl],',')) and not(contains(*[name()=$NameSl],';')) and contains(*[name()=$NameSl],' ')">
				<xsl:call-template name="tokenize">
					<xsl:with-param name="string" select="normalize-space(*[name()=$NameSl])"/>		
					<xsl:with-param name="NodeName" select="$NameNode"/>
					<xsl:with-param name="Nodespace" select="$NameSp"/>
					<xsl:with-param name="delimiters">
						<xsl:text> </xsl:text>
					</xsl:with-param>
				</xsl:call-template>
			</xsl:when>
			<xsl:when test="string-length(*[name()=$NameSl])>number($LenDes) and not(contains(*[name()=$NameSl],',')) and not(contains(*[name()=$NameSl],' ')) and not(contains(*[name()=$NameSl],';'))">
				<xsl:element name="{$NameNode}" namespace="{$NameSp}">
					<xsl:value-of select="substring(normalize-space(*[name()=$NameSl]),1,number($LenDes))"/>
				</xsl:element>
			</xsl:when>
			<xsl:otherwise>
				<xsl:element name="{$NameNode}" namespace="{$NameSp}">
					<xsl:value-of select="normalize-space(*[name()=$NameSl])"/>
				</xsl:element>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>	
	
	<xsl:template name="CheckPortNum">
		<xsl:param name="text"/>
		<xsl:variable name="numtr" select="translate($text,'0123456789','9999999999')"/>
		<xsl:variable name="up_ru_text" select="translate($text,$uppercaserus,$rustext)"/>
		<xsl:variable name="sm_ru_text" select="translate($text,$smallcaserus,$rustext)"/>
		<xsl:variable name="sm_lat_text" select="translate($text,$smallcaseeng,$engtext)"/>
		<xsl:choose>
			<xsl:when test="string-length($text)>0 and string-length($text)!=3  and string-length($text)!=5">2</xsl:when>
			<xsl:when test="string-length($up_ru_text)>0 and contains($up_ru_text,'z')">2</xsl:when>
			<xsl:when test="string-length($sm_ru_text)>0 and contains($sm_ru_text,'z')">2</xsl:when>
			<xsl:when test="string-length($sm_lat_text)>0 and contains($sm_lat_text,'z')">2</xsl:when>
			<xsl:when test="string-length($numtr)>0 and contains($numtr,'9')">1</xsl:when>
			<xsl:otherwise>0</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template name="ChSeallId">
		<xsl:param name="Value"/>
		<xsl:param name="lenVal"/>
		<xsl:variable name="LenVal">
			<xsl:choose>
				<xsl:when test="string-length($lenVal)>0">
					<xsl:value-of select="$lenVal"/>
				</xsl:when>
				<xsl:otherwise>50</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<xsl:choose>
			<xsl:when test="string-length($Value)>number($LenVal) and not(contains($Value,',')) and not(contains($Value,';'))  and not(contains($Value,' '))">0</xsl:when>
			<xsl:when test="string-length($Value)>number($LenVal) and (contains($Value,',') or contains($Value,';') or contains($Value,' '))">
				<xsl:call-template name="ChSeallIdDop">
					<xsl:with-param name="Value"  select="normalize-space($Value)"/>
					<xsl:with-param name="LenVal"  select="$LenVal"/>
				</xsl:call-template>
			</xsl:when>
			<xsl:otherwise>1</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	
	<xsl:template name="ChSeallIdDop">
		<xsl:param name="Value"/>
		<xsl:param name="LenVal"/>
		<xsl:variable name="pos_sim1">
			<xsl:choose>
				<xsl:when  test="contains($Value,',')">
					<xsl:value-of  select="string-length(substring-before($Value,','))"/>
				</xsl:when>
				<xsl:otherwise>0</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<xsl:variable name="pos_sim2">
			<xsl:choose>
				<xsl:when  test="contains($Value,';')">
					<xsl:value-of  select="string-length(substring-before($Value,';'))"/>
				</xsl:when>
				<xsl:otherwise>0</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<xsl:variable name="pos_sim3">
			<xsl:choose>
				<xsl:when  test="contains($Value,' ')">
					<xsl:value-of  select="string-length(substring-before($Value,' '))"/>
				</xsl:when>
				<xsl:otherwise>0</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<xsl:variable name="val_before_sim">
			<xsl:choose>
				<xsl:when  test="$pos_sim1>0 and $pos_sim2>0 and $pos_sim2>$pos_sim1">
					<xsl:value-of select="normalize-space(substring-before($Value,','))"/>
				</xsl:when>
				<xsl:when  test="$pos_sim1>0 and $pos_sim2>0 and $pos_sim1>$pos_sim2">
					<xsl:value-of select="normalize-space(substring-before($Value,';'))"/>
				</xsl:when>
				<xsl:when  test="$pos_sim1>0 and $pos_sim2=0">
					<xsl:value-of select="normalize-space(substring-before($Value,','))"/>
				</xsl:when>
				<xsl:when  test="$pos_sim2>0 and $pos_sim1=0">
					<xsl:value-of select="normalize-space(substring-before($Value,';'))"/>
				</xsl:when>
				<xsl:when  test="$pos_sim3>0 and $pos_sim2=0 and $pos_sim1=0">
					<xsl:value-of select="normalize-space(substring-before($Value,' '))"/>
				</xsl:when>
			</xsl:choose>
		</xsl:variable>
		<xsl:variable name="len_val_before_sim" select="string-length($val_before_sim)"/>
		<xsl:variable name="len_val" select="string-length($Value)"/>
		<xsl:variable name="val_after_sim" select="normalize-space(substring($Value,$len_val_before_sim+1,$len_val - $len_val_before_sim))"/>
		
		<xsl:variable name="len_val_after_sim" select="string-length($val_after_sim)"/>
		<xsl:choose>
			<xsl:when test="number($LenVal)>=$len_val_before_sim and number($LenVal)>=$len_val_after_sim">1</xsl:when>
			<xsl:when test="$len_val_before_sim>number($LenVal)">0</xsl:when>
			<xsl:when test="$len_val_before_sim=0">0</xsl:when>
			<xsl:when test="$len_val_before_sim>0 and number($LenVal)>=$len_val_before_sim and $len_val_after_sim>number($LenVal)">
				<xsl:call-template name="ChSeallIdDop">
					<xsl:with-param name="Value">
						<xsl:choose>
							<xsl:when test="starts-with(normalize-space($val_after_sim),',')">
								<xsl:value-of select="normalize-space(substring-after(normalize-space($val_after_sim),','))"/>
							</xsl:when>
							<xsl:when test="starts-with(normalize-space($val_after_sim),';')">
								<xsl:value-of select="normalize-space(substring-after(normalize-space($val_after_sim),';'))"/>
							</xsl:when>
							<xsl:otherwise>
								<xsl:value-of select="normalize-space($val_after_sim)"/>
							</xsl:otherwise>
						</xsl:choose>
					</xsl:with-param>
					<xsl:with-param name="LenVal"  select="$LenVal"/>
				</xsl:call-template>
			</xsl:when>
			<xsl:otherwise>0</xsl:otherwise>
		</xsl:choose>
	</xsl:template>	

	<xsl:template name="round_value">
		<xsl:param  name="value"/>
		<xsl:param  name="dec"/>
		<xsl:choose>
			<xsl:when test="contains($value,'.')">
				<xsl:variable name="whole" select="substring-before($value,'.')"/>
				<xsl:variable name="frac" select="substring-after($value,'.')"/>
				<xsl:variable name="frac1" select="substring($frac,1,number($dec))"/>
				<xsl:variable name="frac2" select="substring($frac,number($dec)+1,2)"/>
				<xsl:choose>
					<xsl:when test="number($frac1)=9 and string-length($frac2)=2 and number($frac2)>94">
						<xsl:value-of select="round($value  * 100) div 100"/>
					</xsl:when>
					<xsl:otherwise>
						<xsl:variable name="frac21">
							<xsl:if  test="string-length($frac2)>0">
								<xsl:choose>
									<xsl:when test="string-length($frac2)=1">
										<xsl:value-of select="$frac2"/>
									</xsl:when>
									<xsl:when test="string-length($frac2)=2 and number($frac2)>94">
										<xsl:value-of select="floor($frac2 div 10)"/>
									</xsl:when>
									<xsl:otherwise>
										<xsl:value-of select="round($frac2 div 10)"/>
									</xsl:otherwise>
								</xsl:choose>
							</xsl:if>
						</xsl:variable>
						<xsl:value-of select="concat($whole,'.',$frac1,$frac21)"/>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="$value"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template name="ChOrgINN">
		<xsl:param name="country"/>
		<xsl:param name="pref"/>
		<xsl:choose>
			<xsl:when  test="$country='RU' and string-length(normalize-space(*[name()=concat($pref,'INN')]))!=10 and string-length(normalize-space(*[name()=concat($pref,'INN')]))!=12">10 или 12</xsl:when>
			<xsl:when  test="$country='BY' and string-length(normalize-space(*[name()=concat($pref,'INN')]))!=9">9</xsl:when>
			<xsl:when  test="$country='KZ' and string-length(normalize-space(*[name()=concat($pref,'INN')]))!=12">12</xsl:when>
			<xsl:when  test="$country='AM' and string-length(normalize-space(*[name()=concat($pref,'INN')]))!=8">8</xsl:when>
			<xsl:when  test="$country='KG' and string-length(normalize-space(*[name()=concat($pref,'INN')]))!=14">14</xsl:when>
		</xsl:choose>
	</xsl:template>

	<xsl:template name="ValidIdentityCardCode">
		<xsl:param name="text"/>

		<xsl:choose>
			<xsl:when test="string-length($text)=2">
				<xsl:variable name="numtr" select="translate($text,'0123456789','9999999999')"/>
				<xsl:choose>
					<xsl:when test="string-length($numtr)>0 and contains($numtr,'9')">0</xsl:when>
					<xsl:otherwise>1</xsl:otherwise>
				</xsl:choose>
			</xsl:when>
			<xsl:otherwise>
				<xsl:variable name="numd" select="substring($text,3)"/>
				<xsl:variable name="pref" select="substring($text,1,2)"/>
				<xsl:variable name="numpref" select="translate($numd,'0123456789','9999999999')"/>
				<xsl:variable name="up_lat_text" select="translate($pref,$uppercaseeng,$engtext)"/>
				<xsl:choose>
					<xsl:when test="(string-length($numd)=5 and contains($numd,'9')) and string-length($up_lat_text)>0 and contains($up_lat_text,'z')">0</xsl:when>
					<xsl:otherwise>1</xsl:otherwise>
				</xsl:choose>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template> 
	
</xsl:stylesheet>
