<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE xsl:stylesheet  [
	<!ENTITY nbsp   "&#160;">
	<!ENTITY copy   "&#169;">
	<!ENTITY reg    "&#174;">
	<!ENTITY trade  "&#8482;">
	<!ENTITY mdash  "&#8212;">
	<!ENTITY ldquo  "&#8220;">
	<!ENTITY rdquo  "&#8221;"> 
	<!ENTITY pound  "&#163;">
	<!ENTITY yen    "&#165;">
	<!ENTITY euro   "&#8364;">
]>

<!--

 author: David Walker
 copyright: 2010 California State University
 version: $Id$
 package: Pazpar2
 link: http://xerxes.calstate.edu
 license: http://www.gnu.org/licenses/
 
 -->
 
<xsl:stylesheet version="1.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:php="http://php.net/xsl" exclude-result-prefixes="php">

	<xsl:import href="../pazpar2/results.xsl" />
	<xsl:import href="../pazpar2/includes.xsl" />
    <xsl:import href="../pazpar2/eng.xsl" />

    <!-- override javascript-include from ../includes.xsl GS -->
    <xsl:template name="javascript_include"> 
        <xsl:call-template name="jslabels" /> 
            <script src="javascript/jquery/jquery-1.6.2.min.js" language="javascript" type="text/javascript"></script> 
            <script src="javascript/results.js" language="javascript" type="text/javascript"></script>
            <script src="javascript/uls_status.js" language="javascript" type="text/javascript"></script>
            <script src="javascript/pz2_ping.js" language="javascript" type="text/javascript"></script>
    </xsl:template>

    <!-- overriding search_page from ../search/results.xsl to add right sidebar
         for status display. FIXME this is overkill just to do that GS -->
         
	<!--
		TEMPLATE: SEARCH PAGE
	-->

	<xsl:template name="search_page">

		<!-- search box area -->
		
		<div class="yui-ge">
			<div class="yui-u first">
				<h1><xsl:value-of select="$text_search_module" /></h1>
				<xsl:call-template name="searchbox" />
			</div>
			<div class="yui-u">
				<div class="sidebar">
					<xsl:call-template name="sidebar_box" />
				</div>
			</div>
		</div>
	
		<xsl:call-template name="tabs" />

		<xsl:variable name="sidebar">
			<xsl:choose>
				<xsl:when test="//config/search_sidebar = 'right'">
					<xsl:text>right</xsl:text>
				</xsl:when>
				<xsl:otherwise>
					<xsl:text>left</xsl:text>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		
		<!-- results area -->
		
		<div class="">
			<xsl:attribute name="class">
				<xsl:choose>
					<xsl:when test="$sidebar = 'right'">
						<xsl:text>yui-ge</xsl:text>
					</xsl:when>
					<xsl:otherwise>
						<xsl:text>yui-gf</xsl:text>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:attribute>
			
			<!-- results -->
	
			<div>
				<xsl:attribute name="class">
					<xsl:text>yui-u</xsl:text>
					<xsl:if test="$sidebar = 'right'">
						<xsl:text> first</xsl:text>
					</xsl:if>
				</xsl:attribute>	
				<xsl:call-template name="facets_applied" />
		
				<div class="tabs">
					<xsl:call-template name="sort_bar" />
				</div>

		    <!-- insert status info in right column (see local.css) GS -->    
            <div class="sidebar status">
               <div class="box">
                   <xsl:call-template name="status_sidebar" />
               </div>
            </div>

            <div id="results-block">
				<xsl:call-template name="brief_results" />
            </div>

        <!-- move nav to bottom of page GS -->
        <div style="clear: both" />
				<xsl:call-template name="paging_navigation" />
				
				<xsl:call-template name="hidden_tag_layers" />
	
			</div>
			
			<!-- facets, etc. -->
			
			<div>
				<xsl:attribute name="class">
					<xsl:text>yui-u</xsl:text>
					<xsl:if test="$sidebar = 'left'">
						<xsl:text> first</xsl:text>
					</xsl:if>
				</xsl:attribute>		
					
				<div id="search-sidebar" class="sidebar {$sidebar}">				
					<xsl:call-template name="search_sidebar" />
				</div>
			</div>
		</div>	
		
	</xsl:template>

	<!-- 
		TEMPLATE: BRIEF RESULT
		display of results geared toward journals
	-->
	
	<xsl:template name="brief_result">

		<li class="result">
					
			<xsl:variable name="title">
				<xsl:choose>
					<xsl:when test="title_normalized != ''">
						<xsl:value-of select="title_normalized" />
					</xsl:when>
					<xsl:otherwise>
						<xsl:copy-of select="$text_results_no_title" />
					</xsl:otherwise>
				</xsl:choose>
			</xsl:variable>
			
			<a class="results-title" href="{../url_full}"><xsl:value-of select="$title" /></a>
			
			<div class="results-info">
		
                <xsl:choose>
				    <xsl:when test="publisher">
				        <span class="results-author">
				            <strong><xsl:copy-of select="$text_results_publisher" />: </strong><xsl:value-of select="publisher" />
					    </span>
                    </xsl:when>
                    <xsl:when test="organization">
				        <span class="results-author">
				            <strong><xsl:copy-of select="$text_results_publisher" />: </strong><xsl:value-of select="organization" />
					    </span>
                    </xsl:when>
                    <xsl:otherwise/>
                </xsl:choose>

				<!-- custom area for local implementatin to add junk -->
				
				<xsl:call-template name="additional_brief_record_data" />
				
				<div class="record-actions">
					
					<!-- custom area for additional links -->
					
					<xsl:call-template name="additional_record_links" />
					
					<!-- save record -->
					
                <!-- FIXME local SEARCH25 changes GS - FIXME -->
				<!--	<xsl:call-template name="save_record" />
				-->				
				</div>
				
			</div>
			
		</li>
	
	</xsl:template>


</xsl:stylesheet>
