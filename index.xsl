<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet version="2.0" exclude-result-prefixes="#all" 
   xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
   xmlns:xs="http://www.w3.org/2001/XMLSchema"
   xmlns:f="internal"
   xmlns:loc="com.qutoric.sketchpath.functions"
   xmlns:ixsl="http://saxonica.com/ns/interactiveXSLT"
   xmlns:prop="http://saxonica.com/ns/html-property"
   extension-element-prefixes="ixsl">

   <xsl:import href="xmlspectrum/app/xsl/xmlspectrum.xsl"/>
   <xsl:import href="xml-to-string.xsl"/>

   <xsl:template name="main">

   </xsl:template>

   <xsl:template match="*[@id='themes']" mode="ixsl:onchange">
      
      <xsl:variable name="selected-theme-url" select="option[current()/@prop:selectedIndex + 1]/@value"/>

      <xsl:for-each select="id('theme-link'), id('theme-css')">
         <ixsl:set-attribute name="href" select="$selected-theme-url"/>
      </xsl:for-each>
      
   </xsl:template>

   <xsl:template match="button[@id='highlight']" mode="ixsl:onclick">

      <xsl:variable name="source-text" select="id('source')/@prop:value"/>
      
      <xsl:variable name="html" as="element(pre)?">
         <xsl:if test="$source-text">
            <pre class="xslt">
               <xsl:call-template name="get-result-spans">
                  <xsl:with-param name="file-content" select="$source-text"/>
                  <xsl:with-param name="is-xml" select="starts-with(normalize-space($source-text), '&lt;')"/>
                  <xsl:with-param name="is-xsl" select="true()"/>
                  <xsl:with-param name="root-prefix" select="id('xslt-prefix')/@prop:value"/>
                  <xsl:with-param name="indent-size" select="-1"/>
               </xsl:call-template>
            </pre>
         </xsl:if>
      </xsl:variable>

      <xsl:for-each select="id('output')">

         <xsl:variable name="html-text">
            <xsl:call-template name="xml-to-string">
               <xsl:with-param name="node-set" select="$html"/>
            </xsl:call-template>
         </xsl:variable>
         
         <ixsl:set-attribute name="prop:value" select="string($html-text)"/>
      </xsl:for-each>

      <xsl:result-document href="#rendered-output" method="ixsl:replace-content">
         <xsl:sequence select="$html"/>
      </xsl:result-document>

   </xsl:template>

   <xsl:template match="button[@id='clear']" mode="ixsl:onclick">

      <xsl:for-each select="id('source')">
         <ixsl:set-attribute name="prop:value" select="''"/>
      </xsl:for-each>

      <xsl:for-each select="id('output')">
         <ixsl:set-attribute name="prop:value" select="''"/>
      </xsl:for-each>

      <xsl:result-document href="#rendered-output" method="ixsl:replace-content"/>
      
   </xsl:template>
   
   <xsl:template name="get-result-spans">
      <xsl:param name="is-xml" as="xs:boolean"/>
      <xsl:param name="is-xsl" as="xs:boolean"/>
      <xsl:param name="indent-size" as="xs:integer"/>
      <xsl:param name="root-prefix"/>
      <xsl:param name="file-content" as="xs:string"/>
      <xsl:param name="do-trim" select="false()"/>

      <xsl:choose>
         <xsl:when test="$is-xml and $indent-size lt 0 and not($do-trim)">
            <!-- for case where XPath is embedded in XML text -->
            <xsl:sequence select="f:render($file-content, $is-xsl, $root-prefix)"/>
         </xsl:when>
         <xsl:when test="$is-xml">
            <!-- for case where XPath is embedded in XML text and indentation required -->
            <xsl:variable name="spans" select="f:render($file-content, $is-xsl, $root-prefix)"/>
            <xsl:variable name="real-indent" select="if ($indent-size lt 0) then 0 else $indent-size" as="xs:integer"/>
            <xsl:sequence select="f:indent($spans, $real-indent, $do-trim)"/>
         </xsl:when>
         <xsl:otherwise>
            <!-- for case where XPath is standalone -->
            <xsl:sequence select="loc:showXPath($file-content)"/>
         </xsl:otherwise>
      </xsl:choose>
   </xsl:template>

</xsl:stylesheet>
