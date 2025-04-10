<?xml version="1.0"?>
<xsl:stylesheet version="1.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:ovf="http://schemas.dmtf.org/ovf/envelope/1"
  exclude-result-prefixes="ovf">

  <xsl:output method="xml" indent="yes"/>
  <xsl:template match="*">
    <xsl:element name="{local-name()}">
      <xsl:apply-templates select="@* | node()"/>
    </xsl:element>
  </xsl:template>

  <xsl:template match="@*">
    <xsl:attribute name="{local-name()}">
      <xsl:value-of select="."/>
    </xsl:attribute>
  </xsl:template>

  <xsl:template match="comment()|processing-instruction()">
    <xsl:copy/>
  </xsl:template>

  <xsl:template match="text()">
    <xsl:value-of select="."/>
  </xsl:template>
</xsl:stylesheet>

