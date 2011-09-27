<!-- Takes a <descmeta> document (see
  http://text.lib.virginia.edu/dtd/descmeta/descmeta.dtd), outputs
  HTML for display within a <dl> element. -->
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">
  
  <xsl:output method="html"/>
  <xsl:strip-space elements="*"/>
  
  <!-- main template; this controls the order in which elements are handled -->
  <xsl:template match="descmeta">
    <!--
    <xsl:apply-templates select="agent[@type='creator'][@role]"/>
    
    <xsl:variable name="creators_without_role" select="agent[@type='creator'][not(@role)]"/>
    <xsl:if test="$creators_without_role">
      <dt>
        <xsl:text>Creator</xsl:text>
        <xsl:if test="count($creators_without_role) > 1">
          <xsl:text>s</xsl:text>
        </xsl:if>
      </dt>
      <xsl:apply-templates select="$creators_without_role"/>
    </xsl:if>
    -->
    
    <xsl:if test="agent[@type='contributor']">
      <dt>Contributor</dt>
      <xsl:apply-templates select="agent[@type='contributor']"/>
    </xsl:if>
    
    <xsl:if test="agent[@type='provider']">
      <dt>Provider</dt>
      <xsl:apply-templates select="agent[@type='provider']"/>
    </xsl:if>
    
    <xsl:apply-templates select="mediatype"/>
    
    <xsl:if test="physdesc">
      <dt>Description</dt>
      <xsl:apply-templates select="physdesc"/>
    </xsl:if>
    
    <xsl:apply-templates select="place|covplace"/>
    <xsl:apply-templates select="time|covtime"/>
    
    <!-- for the following elements, group multiple occurrences using only one label -->
    <xsl:if test="culture">
      <dt>Culture</dt>
      <xsl:apply-templates select="culture"/>
    </xsl:if>
    <xsl:if test="style">
      <dt>Style</dt>
      <xsl:apply-templates select="style"/>
    </xsl:if>
    <xsl:if test="language">
      <dt>Language</dt>
      <xsl:apply-templates select="language"/>
    </xsl:if>
    <xsl:if test="numbering">
      <dt>Numbering</dt>
      <xsl:apply-templates select="numbering"/>
    </xsl:if>
    
    <xsl:apply-templates select="description[@type]"/>
    <xsl:apply-templates select="description[not(@type)]"/>
    <xsl:apply-templates select="rights"/>
  </xsl:template>
  
  
  <!--
  <xsl:template match="agent[@type='creator'][@role]">
    <dt>Creator (<xsl:value-of select="@role"/>)</dt>
    <dd><author_link><xsl:apply-templates/></author_link></dd>
  </xsl:template>
  
  <xsl:template match="agent[@type='creator'][not(@role)]">
    <dd><xsl:apply-templates/></dd>
  </xsl:template>
  -->
  <xsl:template match="agent">
    <dd>
      <xsl:apply-templates select="name"/>
      <xsl:if test="time/date">
        <xsl:text>, </xsl:text>
        <xsl:apply-templates select="time/date[1]"/>
        <xsl:text>-</xsl:text>
        <xsl:apply-templates select="time/date[2]"/>
      </xsl:if>
    </dd>
  </xsl:template>
  
  <xsl:template match="mediatype[child::form]">
    <dt>Type</dt>
    <xsl:apply-templates select="form"/>
  </xsl:template>
  
  <xsl:template match="place|covplace">
    <xsl:variable name="type" select="@type"/>
    <xsl:choose>
      <xsl:when test="@type">
        <xsl:choose>
          <xsl:when test="preceding-sibling::place[@type=$type]|preceding-sibling::covplace[@type=$type]"/>
          <xsl:otherwise>
            <dt><titlecase>Place (<xsl:value-of select="$type"/>)</titlecase></dt>
            <xsl:apply-templates select="../place[@type=$type]|../covplace[@type=$type]" mode="dd"/>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:when>
      <xsl:otherwise>
        <xsl:choose>
          <xsl:when test="preceding-sibling::place[not(@type)]|preceding-sibling::covplace[not(@type)]"/>
          <xsl:otherwise>
            <dt>Place</dt>
            <xsl:apply-templates select="../place[not(@type)]|../covplace[not(@type)]" mode="dd"/>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  <xsl:template match="place|covplace" mode="dd">
    <xsl:apply-templates select="geogname"/>
  </xsl:template>
  
  <xsl:template match="mediatype/form|geogname|physdesc|culture|style|language|numbering">
    <dd><xsl:apply-templates/></dd>
  </xsl:template>
  
  <xsl:template match="description[@type]">
    <xsl:variable name="type" select="@type"/>
    <xsl:choose>
      <xsl:when test="preceding-sibling::description[@type=$type]"/>
      <xsl:otherwise>
        <dt><titlecase><xsl:value-of select="@type"/></titlecase></dt>
        <xsl:apply-templates select="../description[@type=$type]" mode="dd"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  <xsl:template match="description" mode="dd">
    <dd><xsl:apply-templates/></dd>
  </xsl:template>
  
  <xsl:template match="description[not(@type)]|time|covtime|rights">
    <dt>
      <titlecase>
        <xsl:choose>
          <xsl:when test="@type">
            <xsl:value-of select="@type"/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:choose>
              <xsl:when test="self::time or self::covtime">date</xsl:when>
              <xsl:otherwise><xsl:value-of select="local-name(.)"/></xsl:otherwise>
            </xsl:choose>
          </xsl:otherwise>
        </xsl:choose>
      </titlecase>
    </dt>
    <dd><xsl:apply-templates/></dd>
  </xsl:template>
  
  <!-- ignore these elements -->
  <xsl:template match="pid|presentation|surrogate|relationships"/>
  <xsl:template match="authority|identifier|subject|title|mimetype"/>
  <xsl:template match="descmeta/time"/>
  
</xsl:stylesheet>
