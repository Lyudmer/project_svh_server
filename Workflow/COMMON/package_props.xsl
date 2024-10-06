<?xml version="1.0" encoding="UTF-8"?>

<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:docs="https://documents">
	<xsl:key name="prop" use="@name" match="/Package/package-properties/prop"/>
	<xsl:key name="PackageDOC_ITEM" use="name(parent::*)" match="/Package/*/*[ name() = concat(name(parent::*), '_ITEM') ]"/>
	<xsl:key name="PackageForFindDOC_ITEM" use="name(parent::*)" match="/Package/Package/*/*[ name() = concat(name(parent::*), '_ITEM') ]"/>
	<xsl:key name="PackageDocument" match="/Package/*" use="@*[local-name()='CfgName']"/>
	<xsl:key name="PackageDocument" match="/Package/*/*" use="concat(ancestor::*[1]/@*[local-name()='CfgName'], '/',local-name())"/>
	<xsl:key name="PackageDocument" match="/Package/*/*/*" use="concat(ancestor::*[2]/@*[local-name()='CfgName'],  '/',local-name(ancestor::*[1]), '/',local-name())"/>
	<xsl:key name="PackageDocument" match="/Package/*/*/*/*" use="concat(ancestor::*[3]/@*[local-name()='CfgName'], '/',local-name(ancestor::*[2]), '/',local-name(ancestor::*[1]), '/',local-name())"/>
	<xsl:key name="PackageDocument" match="/Package/*/*/*/*/*" use="concat(ancestor::*[4]/@*[local-name()='CfgName'], '/',local-name(ancestor::*[3]), '/',local-name(ancestor::*[2]), '/',local-name(ancestor::*[1]), '/',local-name())"/>
	<xsl:key name="PackageDocument" match="/Package/*" use="concat(@*[local-name()='CfgName'], ':',local-name())"/>
	<xsl:key name="PackageDocument" match="/Package/*/*" use="concat(ancestor::*[1]/@*[local-name()='CfgName'], ':',local-name(ancestor::*[1]), '/',local-name())"/>
	<xsl:key name="PackageDocument" match="/Package/*/*/*" use="concat(ancestor::*[2]/@*[local-name()='CfgName'], ':',local-name(ancestor::*[2]), '/',local-name(ancestor::*[1]), '/',local-name())"/>
	<xsl:key name="PackageDocument" match="/Package/*/*/*/*" use="concat(ancestor::*[3]/@*[local-name()='CfgName'], ':',local-name(ancestor::*[3]), '/',local-name(ancestor::*[2]), '/',local-name(ancestor::*[1]), '/',local-name())"/>
	<xsl:key name="PackageDocument" match="/Package/*/*/*/*/*" use="concat(ancestor::*[4]/@*[local-name()='CfgName'], ':',local-name(ancestor::*[4]), '/',local-name(ancestor::*[3]), '/',local-name(ancestor::*[2]), '/',local-name(ancestor::*[1]), '/',local-name())"/>
	<xsl:key name="PackageDocument" match="/Package/*" use="local-name()"/>
	<xsl:key name="PackageDocument" match="/Package/*/*" use="concat(local-name(ancestor::*[1]), '/',local-name())"/>
	<xsl:key name="PackageDocument" match="/Package/*/*/*" use="concat(local-name(ancestor::*[2]), '/',local-name(ancestor::*[1]), '/',local-name())"/>
	<xsl:key name="PackageDocument" match="/Package/*/*/*/*" use="concat(local-name(ancestor::*[3]), '/',local-name(ancestor::*[2]), '/',local-name(ancestor::*[1]), '/',local-name())"/>
	<xsl:key name="PackageDocument" match="/Package/*/*/*/*/*" use="concat(local-name(ancestor::*[4]), '/',local-name(ancestor::*[3]), '/',local-name(ancestor::*[2]), '/',local-name(ancestor::*[1]), '/',local-name())"/>
	<xsl:key name="local-descendant" match="*[ string(namespace-uri()) ]" use="concat(generate-id(ancestor::node()[2]), '/', local-name(ancestor::*[1]), '/', local-name())"/>
	<xsl:key name="local-descendant" use="concat(generate-id(ancestor::node()[3]), '/', local-name(ancestor::*[2]), '/', local-name(ancestor::*[1]), '/', local-name())" match="*[ string(namespace-uri()) ]"/>
	<xsl:key name="local-descendant" use="concat(generate-id(ancestor::node()[4]), '/', local-name(ancestor::*[3]), '/', local-name(ancestor::*[2]), '/', local-name(ancestor::*[1]), '/', local-name())" match="*[ string(namespace-uri()) ]"/>
	<xsl:key name="local-descendant" use="concat(generate-id(ancestor::node()[5]), '/', local-name(ancestor::*[4]), '/', local-name(ancestor::*[3]), '/', local-name(ancestor::*[2]), '/', local-name(ancestor::*[1]), '/', local-name())" match="*[ string(namespace-uri()) ]"/>
	<xsl:key name="local-descendant" use="concat(generate-id(ancestor::node()[6]), '/', local-name(ancestor::*[5]), '/', local-name(ancestor::*[4]), '/', local-name(ancestor::*[3]), '/', local-name(ancestor::*[2]), '/', local-name(ancestor::*[1]), '/', local-name())" match="*[ string(namespace-uri()) ]"/>
	<xsl:key name="local-descendant" use="concat(generate-id(ancestor::node()[7]), '/', local-name(ancestor::*[6]), '/', local-name(ancestor::*[5]), '/', local-name(ancestor::*[4]), '/', local-name(ancestor::*[3]), '/', local-name(ancestor::*[2]), '/', local-name(ancestor::*[1]), '/', local-name())" match="*[ string(namespace-uri()) ]"/>
	<xsl:key name="local-descendant" use="concat(generate-id(ancestor::node()[8]), '/', local-name(ancestor::*[7]), '/', local-name(ancestor::*[6]), '/', local-name(ancestor::*[5]), '/', local-name(ancestor::*[4]), '/', local-name(ancestor::*[3]), '/', local-name(ancestor::*[2]), '/', local-name(ancestor::*[1]), '/', local-name())" match="*[ string(namespace-uri()) ]"/>

</xsl:stylesheet>
