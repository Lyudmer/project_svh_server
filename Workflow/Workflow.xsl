<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:docs="http://documents">
	<xsl:include href="COMMON/package_props.xsl"/>
	<xsl:include href="COMMON/valid_archId_doc.xsl"/>
<!-- Локальное время формате YYYY-MM-DDTHH:mm:SS -->
	<xsl:param name="Now">2024-07-12T12:34:11</xsl:param>
	<xsl:param name="pkgstatus">3</xsl:param>
    
    <xsl:variable name="nsipath" select="document('NSI/TranspNSIXml.xml')"/>
	<xsl:variable name="propRefDocumentID" select="string(key('prop', 'RefDocumentID'))"/>
	<xsl:variable name="propChainLocked" select="string(key('prop', 'ChainLocked'))"/>
	<xsl:variable name="propCustomCode" select="string(key('prop', 'CustomCode'))"/>
	
	<xsl:variable name="last_doc_pkg" select="/Package/*[not(contains(name(),'DesNotif_PIResult'))][position()=last()]"/>
	
	<xsl:variable name="pkgload14004" select="/Package/*[contains(local-name(),'ErrorList')][contains(@*[local-name()='CfgName'],'CMN.14004')][position()=last()]"/>

	<xsl:variable name="pid-parent" select="/Package/@pid"/>

	<xsl:variable name="count_doc_pkg" select="count(child::*/@*[string-length(name())>0 and contains(name(),'ctmtd') and not(contains(.,'DesNotif'))])"/>
	
	<xsl:template match="/">
		<xsl:choose>
			<xsl:when test="$pkgstatus=1">
				<Actions>
					<SetProperty name="ChainLocked">true</SetProperty>
					<SetState>3</SetState>
				</Actions>
			</xsl:when>
			<xsl:otherwise>
				<xsl:if test="count(Package)=0">
					<xsl:message terminate="yes">В пакете отсутствуют документы для отправки</xsl:message>
				</xsl:if>
				<xsl:apply-templates select="Package"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	<xsl:template match="/Package">
		<xsl:variable name="StatusResult">,99,4,8,</xsl:variable>
		<Actions>
			<xsl:choose>
				<xsl:when  test="contains($StatusResult,concat(',',$pkgstatus,','))">
					<xsl:call-template name="result"/>
					<xsl:if test="$pkgstatus=4">
						<SetProperty name="ChainLocked">false</SetProperty>
					</xsl:if>
				</xsl:when>
				<xsl:otherwise>
					<xsl:call-template name="svh_send"/>
				</xsl:otherwise>
			</xsl:choose>
		</Actions>
	</xsl:template>
	
	<xsl:template name="svh_send">
		<xsl:choose>
			<xsl:when test="$pkgstatus=3">
				<Delete name="DesNotif_PIResult.cfg.xml"/>
				<FLK>
					<xsl:attribute name="name">FTS/FLK/DesNotif_PIResult.FLK.xsl</xsl:attribute>
				</FLK>
				<FLK>
					<xsl:attribute name="name">FTS/FLK/DesNotif_PIResultWHInv.FLK.xsl</xsl:attribute>
				</FLK>
				<xsl:call-template name="svh_send_fts"/>
			</xsl:when>
			<xsl:when test="$pkgstatus=208">
				<xsl:call-template name="all_docs_registred"/>
			</xsl:when>
			<xsl:when test="$pkgstatus=217">
				<xsl:call-template name="make_inventory"/>
			</xsl:when>
			<xsl:when test="($pkgstatus=99 or $pkgstatus=4) and count(DesNotif_PIResult)>0">
				<xsl:call-template name="result"/>
			</xsl:when>
			<xsl:when test="$pkgstatus=214">
				<xsl:call-template name="svh_make_result"/>
			</xsl:when>
			<xsl:otherwise/>
		</xsl:choose>
	</xsl:template>
	<xsl:template name="svh_send_fts">
		<xsl:variable name="customsCode" select="/Package/WHDOCINVENTORY/WHDOCINVENTORY_ITEM/Receiver_Customs_Code"/>
		<Transform>
			<xsl:attribute name="name">FTS/Package.Armti-EDContainer.xsl</xsl:attribute>
			<with-param name="Now">
				<xsl:value-of select="$Now"/>
			</with-param>
			<with-param name="IncludeInventory">WHDOCINVENTORY</with-param>
		</Transform>
		<Save name="armti.cfg.xml"/>
		<CheckSchema>
			<xsl:attribute name="name">FTS/Schema/ED_Container.xsd</xsl:attribute>
		</CheckSchema>
		<CheckEDContainer>
			<xsl:attribute name="dir">FTS/Schema/</xsl:attribute>
		</CheckEDContainer>

		<Transform name="COMMON/prepare_docs_for_arch.xsl">
			<with-param name="predefinedCustomsCode">
				<xsl:value-of select="$customsCode"/>
			</with-param>
		</Transform>
		<Transform name="COMMON/prepare_docs_for_arch_svhinventory.xsl"/>
		<ExtractEDContainer documentName="archive-rtu-doc.cfg.xml"/>
		<SetState>5</SetState>
	</xsl:template>

	<xsl:template name="all_docs_registred">
		<xsl:variable name="ValidId">
			<xsl:call-template name="validId_doc"/>
		</xsl:variable>
		<xsl:if test="count(//Package/DesNotif_PIResult[contains(@*[local-name()='CfgName'],'archive-rtu-doc-result.cfg.xml')])>=count(//Package/*[string-length(@*[local-name()='customsCode'])>0]) and number($ValidId)=0">
			<SetState>217</SetState>
		</xsl:if>
	</xsl:template>
	<xsl:template name="make_inventory">
		<Transform>
			<xsl:attribute name="name">FTS/ArmtiEDContainerWHDocInventory.xsl</xsl:attribute>
			<with-param name="Now"><xsl:value-of select="$Now"/></with-param>
		</Transform>
		<xsl:call-template name="createGUID-WHInventory"/>
		<CheckSchema>
			<xsl:attribute name="name">FTS/Schema/WHDocInventory.xsd</xsl:attribute>
		</CheckSchema> 
		<Save name="whinventory.cfg.xml"/>
		<SetState>210</SetState>
	</xsl:template>
	<xsl:template name="svh_make_result">
		<Transform name="COMMON/package_add_confirmwhdocreg.xsl"/>
		<Save name="ConfirmWHDocReg.cfg.xml"/>
	</xsl:template>
	
	<xsl:template name="result">
		<xsl:choose>
			<xsl:when test="$pkgstatus=4 and count($pkgload14004)>0">
				<Transform name="COMMON/package.error.xsl"/>
			</xsl:when>
			<xsl:otherwise>
				<Transform name="COMMON/package.result_complete.xsl">
					<with-param name="PkgStatus" select="$PkgStatus"/>
				</Transform>
			</xsl:otherwise>
		</xsl:choose>
		<Save name="DesNotif_PIResult.cfg.xml"/>
		<xsl:if test="$pkgstatus=4 and count($pkgload14004)>0">
			<Delete name="CMN.14004.cfg.xml"/>
		</xsl:if>
	</xsl:template>
	<xsl:template name="del_doc_result">
		<Delete name="DesNotif_PIResult.cfg.xml"/>
		<Delete name="archive-doc.cfg.xml"/>
		<Delete name="archive-doc-result.cfg.xml"/>
		<Delete name="armti.cfg.xml"/>
	</xsl:template>
	<xsl:template name="createGUID-WHInventory">
		<xsl:variable name="WHDocInventory" select="'*[ &quot;WHDocInventory&quot; = local-name() ]'"/>
		<xsl:variable name="InventDocument" select="'/*[ &quot;InventDocument&quot; = local-name() ]'"/>
		<xsl:variable name="InventLineID" select="'/*[ &quot;InventLineID&quot; = local-name() ]'"/>
		<xsl:variable name="xpath" select="concat('//', $WHDocInventory, $InventDocument, $InventLineID)"/>
		<CreateGUID>
			<xsl:attribute name="xpath"><xsl:value-of select="$xpath"/></xsl:attribute>
		</CreateGUID>
	</xsl:template>
	
</xsl:stylesheet>
