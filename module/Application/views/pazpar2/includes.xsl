<?xml version="1.0" encoding="UTF-8"?>


<xsl:stylesheet version="1.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:php="http://php.net/xsl" exclude-result-prefixes="php">

<xsl:template name="breadcrumb_start">
    <a>
        <xsl:attribute name="href">
            <xsl:value-of select="//request/controller"/>
            <xsl:text>?</xsl:text>
            <xsl:for-each select="//request/session/targetnames">
                <xsl:text>&amp;target=</xsl:text><xsl:value-of select="." />
            </xsl:for-each>
        </xsl:attribute>
        <xsl:text>Library selection</xsl:text>
    </a>
</xsl:template>
    
    <!-- include the current session values -->
    <xsl:template name="session-data">
        <!-- see http://www.w3.org/TR/html5/elements.html#embedding-custom-non-visible-data-with-the-data-attributes -->
        <!-- this is used by javascript and not a real hidden field -->
        <span id="pz2session" data-value="{//request/session/pz2session}" data-completed="{//request/session/completed}" data-querystring="{//request/session/querystring}" />
    </xsl:template>

    <!-- account dropped for now - original in views/includes -->
	<xsl:template name="account_sidebar">
		<div id="account" class="box">
			<h2><xsl:copy-of select="$text_header_myaccount" /></h2>
			<ul>
        <!--
				<li id="login-option">
					<xsl:choose>
						<xsl:when test="//request/session/role and //request/session/role != 'local'">
							<a id="logout">
							<xsl:attribute name="href"><xsl:value-of select="//navbar/logout_link" /></xsl:attribute>
								<xsl:copy-of select="$text_header_logout" />
							</a>
						</xsl:when>
						<xsl:otherwise>
							<a id="login">
							<xsl:attribute name="href"><xsl:value-of select="//navbar/login_link" /></xsl:attribute>
								<xsl:copy-of select="$text_header_login" />
							</a>
						</xsl:otherwise>
					</xsl:choose>
				</li>
		-->	
				<li id="my-saved-records" class="sidebar-folder">
					<xsl:call-template name="img_save_record">
						<xsl:with-param name="id">folder</xsl:with-param>
						<xsl:with-param name="test" select="//navbar/element[@id='saved_records']/@numSessionSavedRecords &gt; 0" />
					</xsl:call-template>
					<xsl:text> </xsl:text>
			<!--		<a>
					<xsl:attribute name="href"><xsl:value-of select="//navbar/my_account_link" /></xsl:attribute>
			-->			<xsl:copy-of select="$text_header_savedrecords" />
			<!--		</a>
			-->	</li>
			</ul>
		</div>
	</xsl:template>

	<xsl:template name="sidebar_box">
		<div id="account" class="box">
			<h2><xsl:copy-of select="$text_header_myaccount" /></h2>
			<ul>
                <xsl:if test="//config/aim25_hits = 'true'">
		            <xsl:call-template name="aim25_hits"/>
                </xsl:if>
                <xsl:if test="//config/search_copac = 'true'">
		            <xsl:call-template name="search_copac"/>
                </xsl:if>
            </ul>
        </div>
    </xsl:template>


    <xsl:template name="search_copac">
      <xsl:if test="//externalLinks/COPAC">
        <li id="search_copac">
            <p>Try outside the M25 libraries with <a href="{//externalLinks/COPAC}" target="_blank">the same search in COPAC</a></p>
        </li>
      </xsl:if>
    </xsl:template>

    <xsl:template name="aim25_hits">
        <li class="hidden" id="aim25-hits">
            <p>Also found: <span id="aim25-hitcount"></span> AIM25 <a href="" target="_blank">archive collections</a> that may relate to your search</p>
        </li>
    </xsl:template>

    <!-- override search/results tab so no count unless live -->
    <xsl:template name="tab"> 
        <xsl:for-each select="option"> 
            <li id="tab-{@id}">
                <xsl:choose>
                    <xsl:when test="@current = 1"> 
                        <xsl:attribute name="class">here</xsl:attribute> 
                        <a href="{@url}"> 
                            <xsl:value-of select="@public" /> <xsl:text> </xsl:text> 
                        <!-- count is wrong anyway! -->
                        <!--    <xsl:call-template name="tab_hit" /> -->
                        </a> 
                    </xsl:when>
                    <xsl:otherwise>
                        <a href="{@url}"> 
                            <xsl:value-of select="@public" />  
                        </a> 
                    </xsl:otherwise>
                </xsl:choose>
            </li> 
        </xsl:for-each> </xsl:template>

</xsl:stylesheet>
