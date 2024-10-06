<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:docs="https://documents.ru">
	<xsl:param name="pkgstatus"/>
	<xsl:param name="error_message"/>
	<xsl:template match="/">
		<xsl:choose>
			<xsl:when test="string-length($error_message)>0">
				<xsl:call-template name="DesNotif_PIResult_Res_Mess"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:apply-templates select="/Package/DesNotif_PIResult[@pid = /Package/@pid][last()]"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	<xsl:key name="containerKey" match="//CONOSAMENTGOODS_ITEM/ContainerNum/text()" use="."/>
	
	<xsl:template match="//CONTAINER_ITEM">
		<xsl:value-of select="ContainerID"/>
		<xsl:text>, </xsl:text>
	</xsl:template>
		
	<xsl:template match="DesNotif_PIResult">
		<xsl:call-template name="DesNotif_PIResult_Res"/>
	</xsl:template>
	<xsl:template name="DesNotif_PIResult_Res_Mess">
		<xsl:variable name="PidPkg">
			<xsl:choose>
				<xsl:when test="name(*)='Package'">
					<xsl:value-of select="*/@pid"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="../@pid"/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<DesNotif_PIResult xmlns:docs="https://documents.ru" docs:CfgName="DesNotif_PIResult.cfg.xml">
			<xsl:attribute name="pid"><xsl:value-of select="$PidPkg"/></xsl:attribute>
			<DesNotif_PIResult_ITEM>
				<PackageId><xsl:value-of select="$PidPkg"/></PackageId>
				<PackageStatus>REJECT</PackageStatus>
				<ResultInformation>
					<RESULTINFORMATION_ITEM>
						<ResultCode>00.00000.00</ResultCode>
						<ResultDescription><xsl:value-of select="$error_message"/></ResultDescription>
						<ResultCategory>ERROR</ResultCategory>
					</RESULTINFORMATION_ITEM>
				</ResultInformation>
			</DesNotif_PIResult_ITEM>
		</DesNotif_PIResult>
	</xsl:template>
	<xsl:template name="DesNotif_PIResult_Res" xmlns:docs="https://documents.ru">
		<DesNotif_PIResult xmlns:docs="https://documents.ru" docs:CfgName="DesNotif_PIResult.cfg.xml">
			<xsl:for-each select="@*[not(contains(local-name(),'CfgName'))]">
				<xsl:attribute name="{local-name()}"><xsl:value-of select="."/></xsl:attribute>
			</xsl:for-each>
			<DesNotif_PIResult_ITEM>
				<xsl:variable name="DocumentID" select="DesNotif_PIResult_ITEM/DocumentID"/>
				<xsl:variable name="TIN" select="string(/Package/package-properties/prop[@name='TIN'])"/>
				<PackageId>
					<xsl:choose>
						<xsl:when test="name(*)='Package'">
							<xsl:value-of select="*/@pid"/>
						</xsl:when>
						<xsl:otherwise>
							<xsl:value-of select="../@pid"/>
						</xsl:otherwise>
					</xsl:choose>
				</PackageId>
				<PackageStatus>
					<xsl:choose>
						<xsl:when test="$PkgStatus=4 and count(DesNotif_PIResult_ITEM/ResultInformation/RESULTINFORMATION_ITEM[ResultCategory='ERROR' or (ResultCategory=3 and ResultCode='10.00008.01')])>0">REJECT</xsl:when>
						<xsl:otherwise>ACCEPT</xsl:otherwise>
					</xsl:choose>
				</PackageStatus>
				<xsl:choose>
					<xsl:when test="string-length($DocumentID) > 0">
						<DocumentID><xsl:value-of select="$DocumentID"/></DocumentID>
					</xsl:when>
					<xsl:when test="string-length($TIN) > 0">
						<DocumentID><xsl:value-of select="$TIN"/></DocumentID>
					</xsl:when>
					<xsl:when test="count($DocumentID) > 0">
						<DocumentID/>
					</xsl:when>
				</xsl:choose>
				<xsl:variable name="node-not-copy">,ResultInformation,DocumentID,PackageId,PackageStatus,NumBill,Container,</xsl:variable>
				<xsl:call-template name="copy-node-res">
					<xsl:with-param  name="node-copy" select="DesNotif_PIResult_ITEM/*[not(contains($node-not-copy,concat(',',local-name(),',')))]"/>
				</xsl:call-template>
				<xsl:for-each select="DesNotif_PIResult_ITEM/Response | DesNotif_PIResult_ITEM/ResultInformation">
					<ResultInformation>
						<xsl:for-each select="ResultInformation | RESULTINFORMATION_ITEM">
							<RESULTINFORMATION_ITEM>
								<xsl:for-each select="child::*">
									<xsl:choose>
										<xsl:when test="not(contains(local-name(),'ResultDescription'))">
											<xsl:choose>
												<xsl:when test="string-length(.)>0">
													<xsl:element name="{local-name()}">
														<xsl:value-of select="."/>
													</xsl:element>
												</xsl:when>
												<xsl:otherwise><xsl:element name="{local-name()}"/></xsl:otherwise>
											</xsl:choose>
										</xsl:when>
										<xsl:otherwise>
											<xsl:call-template name="ResDes"/>
										</xsl:otherwise>
									</xsl:choose>
								</xsl:for-each>
							</RESULTINFORMATION_ITEM>
						</xsl:for-each>
					</ResultInformation>		
				</xsl:for-each>
				<Container>
					<xsl:for-each select="//CONOSAMENTGOODS_ITEM/ContainerNum/text()[generate-id()=generate-id(key('containerKey',.)[1])]">
						<xsl:value-of select="concat(.,' ')"/>
					</xsl:for-each>
				</Container>
				<NumBill>
					<xsl:for-each select="//RegNum[name(parent::*)='CONOSAMENT_ITEM']">
						<xsl:value-of select="."/>
						<xsl:if test="position()!=last()">, </xsl:if>
					</xsl:for-each>
				</NumBill>
			</DesNotif_PIResult_ITEM>
		</DesNotif_PIResult>
	</xsl:template>
	<xsl:template match="NumBill"/>
	<xsl:template match="Vessel"/>
	<xsl:template match="ResultInformation">
		<xsl:variable name="cDesAll" select="count(//DesNotif_PIResult[(string-length(@*[local-name()='CfgName'])>0 and @*[local-name()='CfgName']!='archive-rtu-doc-result.cfg.xml' and @*[local-name()='CfgName']!='DesNotif_PIResult_RzdPI.cfg.xml') or string-length(@*[local-name()='CfgName'])=0]/DesNotif_PIResult_ITEM/ResultInformation/RESULTINFORMATION_ITEM[contains(ResultCode,'10.00008.01') and contains(ResultDescription,'Невозможно разместить документ') and contains(ResultDescription,'Выберите другой код для документа в описи')])"/>
		<xsl:variable name="DesText">
			<xsl:if test="contains(ResultDescription,'Невозможно разместить документ') and not(contains(ResultDescription,'Выберите другой код для документа в описи'))">
				<xsl:text>Выберите другой код для документа в описи. Код не соответствует форме, в которой документ добавлен в пакет. Отказ получен от таможенной системы "Электронный архив декларанта": </xsl:text>
			</xsl:if>
			<xsl:value-of select="RESULTINFORMATION_ITEM/ResultDescription"/>
		</xsl:variable>
		<ResultInformation>
			<xsl:choose>
				<xsl:when test="$PkgStatus=4 and contains(RESULTINFORMATION_ITEM/ResultCode,'10.00008.01') and (($cDesAll=0 and contains(RESULTINFORMATION_ITEM/ResultDescription,'Невозможно разместить документ')) or ($cDesAll>0 and not(contains(RESULTINFORMATION_ITEMResultDescription,'Выберите другой код для документа в описи'))))">
					<xsl:apply-templates select="RESULTINFORMATION_ITEM[(string-length(../../../@*[local-name()='CfgName'])>0 and ../../../@*[local-name()='CfgName']!='archive-rtu-doc-result.cfg.xml' and ../../../@*[local-name()='CfgName']!='DesNotif_PIResult_RzdPI.cfg.xml') or string-length(../../../@*[local-name()='CfgName'])=0]">
						<xsl:with-param name="Des" select="$DesText"/>
					</xsl:apply-templates>
				</xsl:when>
				<xsl:otherwise>
					<xsl:apply-templates select="/Package/DesNotif_PIResult[(string-length(@*[local-name()='CfgName'])>0 and @*[local-name()='CfgName']!='archive-rtu-doc-result.cfg.xml' and @*[local-name()='CfgName']!='DesNotif_PIResult_RzdPI.cfg.xml') or string-length(@*[local-name()='CfgName'])=0]/DesNotif_PIResult_ITEM/ResultInformation/RESULTINFORMATION_ITEM"/>
				</xsl:otherwise>
			</xsl:choose>
		</ResultInformation>
	</xsl:template>
	<!-- Identity transformation - full document copy -->
	<xsl:template match="@*|node()" >
		<xsl:param name="Des"/>
		<xsl:copy>
			<xsl:apply-templates select="@*|node()">
				<xsl:with-param name="Des" select="$Des"/>
			</xsl:apply-templates>
		</xsl:copy>
	</xsl:template>
	<xsl:template match="ResultDescription">
		<xsl:param name="Des"/>
		<xsl:call-template name="ResDes">
			<xsl:with-param name="Des" select="$Des"/>
		</xsl:call-template>
	</xsl:template>

	<xsl:template name="ResDes">
		<xsl:param name="Des"/>
		<xsl:choose>
			<xsl:when test="$PkgStatus=4 and contains(../ResultCode,'10.00008.01') and string-length($Des)>0">
				<xsl:element name="{local-name()}">
					<xsl:value-of select="$Des"/>
				</xsl:element>
			</xsl:when>
			<xsl:otherwise>
				<xsl:element name="{local-name()}">
					<xsl:value-of select="."/>
				</xsl:element>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	<xsl:template name="copy-node-res">
		<xsl:param name="node-copy"/>
		<xsl:for-each select="$node-copy">
			<xsl:choose>
				<xsl:when test="count(child::*)>0">
					<xsl:element name="{local-name()}">
						<xsl:for-each select="child::*">
							<xsl:call-template name="copy-node-res">
								<xsl:with-param  name="node-copy" select="."/>
							</xsl:call-template>
						</xsl:for-each>	
					</xsl:element>
				</xsl:when>
				<xsl:otherwise>
					<xsl:choose>
					<xsl:when test="string-length(.)>0">
						<xsl:element name="{local-name()}">
							<xsl:value-of select="."/>
						</xsl:element>
					</xsl:when>
					<xsl:otherwise><xsl:element name="{local-name()}"/></xsl:otherwise>
				</xsl:choose>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:for-each>
	</xsl:template>
</xsl:stylesheet>
