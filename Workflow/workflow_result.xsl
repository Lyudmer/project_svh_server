<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

	<xsl:template name="result">
		<xsl:if test="$pkgstatus=99">
			<xsl:variable name="TIN" select="/Package/DesNotif_PIResult[last()]/DesNotif_PIResult_ITEM/DocumentID"/>
			<xsl:variable name="RefDocumentID" select="/Package/DesNotif_PIResult[last()]/DesNotif_PIResult_ITEM/RefDocumentID"/>
			<xsl:if test="string-length($TIN)>0">
				<SetProperty name="TIN"><xsl:value-of select="$TIN"/></SetProperty>
			</xsl:if>
			<xsl:if test="string-length($RefDocumentID)>0">
				<SetProperty name="RefDocumentID"><xsl:value-of select="$RefDocumentID"/></SetProperty>
			</xsl:if>
			<xsl:if test="package-properties/prop[@name='LockChainAfterConfirm']='true'">
				<SetProperty name="ChainLocked">true</SetProperty>
			</xsl:if>	
		</xsl:if>
		<xsl:choose>
			<xsl:when test="$pkgstatus=4 and count($pkgload14004)>0">
				<Transform name="COMMON/Package.ForAll_Error.xsl"/>
			</xsl:when>
			<xsl:otherwise>
				<Transform name="COMMON/Package.DesNotif_PIResult_Complete.xsl">
					<with-param name="PkgStatus" select="$PkgStatus"/>
				</Transform>
			</xsl:otherwise>
		</xsl:choose>
		<Save name="DesNotif_PIResult.cfg.xml"/>
		<xsl:if test="$pkgstatus=4 and count($pkgload14004)>0">
			<Delete name="CMN.14004.cfg.xml"/>
		</xsl:if>
	</xsl:template>
</xsl:stylesheet>
