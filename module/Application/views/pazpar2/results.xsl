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

	<xsl:import href="../includes.xsl" /> 
	<xsl:import href="../search/results.xsl" />
	<xsl:import href="includes.xsl" />
    <xsl:import href="eng.xsl" />

    <!-- override javascript-include from ../includes.xsl GS -->
    <xsl:template name="javascript_include"> 
        <xsl:call-template name="jslabels" /> 
            <script src="javascript/jquery/jquery-1.6.2.min.js" language="javascript" type="text/javascript"></script> 
            <script src="javascript/results.js" language="javascript" type="text/javascript"></script>
            <script src="javascript/pz2_status.js" language="javascript" type="text/javascript"></script>
            <script src="javascript/pz2_ping.js" language="javascript" type="text/javascript"></script>
    </xsl:template>

    <!--  hidden field setting called from ../includes.xsl GS -->
    <xsl:template name="searchbox_hidden_fields_local">
        <!-- see http://www.w3.org/TR/html5/elements.html#embedding-custom-non-visible-data-with-the-data-attributes -->
        <!-- this is used by javascript and not a real hidden field -->
        <span id="pz2session" data-value="{//request/session/pz2session}" data-completed="{//request/session/completed}" data-querystring="{//request/session/querystring}" />
        <xsl:for-each select="//request/session/targetnames">
            <input type="hidden" name="target" value="{.}" />
        </xsl:for-each>
    </xsl:template>

	<xsl:output method="html" encoding="utf-8" indent="yes" doctype-public="-//W3C//DTD HTML 4.01 Transitional//EN" doctype-system="http://www.w3.org/TR/html4/loose.dtd"/>

	<xsl:template match="/*">
		<xsl:call-template name="surround">
			<xsl:with-param name="surround_template">none</xsl:with-param>
			<xsl:with-param name="sidebar">none</xsl:with-param>
		</xsl:call-template>
	</xsl:template>
    
    <xsl:template name="breadcrumb">
        <xsl:call-template name="breadcrumb_start"/>
        <xsl:value-of select="$text_breadcrumb_separator" />
        <xsl:value-of select="$text_search_results" />
    </xsl:template>

	<xsl:template name="page_name">
		Search Results
	</xsl:template>
	
	<xsl:template name="title">
		<xsl:value-of select="//request/query" />
	</xsl:template>
	
	<xsl:template name="main">
		<xsl:call-template name="search_page" />
	</xsl:template>

    <xsl:template name="additional_brief_record_data" >
        <xsl:variable name="text_results_location">Available from</xsl:variable>
        <xsl:variable name="recid">
            <xsl:value-of select="./record_id" />
        </xsl:variable>

        <xsl:if test="edition"> 
            <span class="results-edition"> 
                <strong><xsl:copy-of select="$text_results_edition" />: </strong><xsl:value-of select="edition" /> 
            </span> 
        </xsl:if>

        <strong><xsl:copy-of select="$text_results_location" />: </strong>
        <span class="results-holdings">
        <ul>
        <xsl:for-each select="locations/*">
            <li>
                <a href="{../../../url_for_item}&amp;target={name(.)}"><xsl:value-of select="."/></a> 
                <!-- <xsl:value-of select="."/>  -->
            </li>
        </xsl:for-each>
        </ul>
        </span>
    </xsl:template>


	<!--
		TEMPLATE: SORT BAR
        overriding version from search/results.xsl to allow for progress bar GS
	-->

	<xsl:template name="sort_bar">
	
		<xsl:choose>
            <!-- when finished as well -->
			<xsl:when test="//bytarget/finished=1 and results/total = '0'">
				<xsl:call-template name="no_hits" />
			</xsl:when>
            <!-- when not finished and progress less than 1 -->
            <xsl:when test="//bytarget/progress &lt; 100" >
                <div id="progress_container">
                    <div id="progress" style="width:0%"></div>
                </div>
            </xsl:when>
			<xsl:otherwise>
	
				<div id="sort">
					<div class="yui-g" style="width: 100%">
						<div class="yui-u first">
							<xsl:copy-of select="$text_metasearch_results_summary" />
						</div>
						<div class="yui-u">
							<xsl:choose>
								<xsl:when test="//sort_display">
									<div id="sort-options">
										<xsl:copy-of select="$text_results_sort_by" /><xsl:text>: </xsl:text>
										<xsl:for-each select="//sort_display/option">
											<xsl:choose>
												<xsl:when test="@active = 'true'">
													<strong><xsl:value-of select="text()" /></strong>
												</xsl:when>
												<xsl:otherwise>
													<xsl:variable name="link" select="@link" />
													<a href="{$link}">
														<xsl:value-of select="text()" />
													</a>
												</xsl:otherwise>
											</xsl:choose>
											<xsl:if test="following-sibling::option">
												<xsl:text> | </xsl:text>
											</xsl:if>
										</xsl:for-each>
									</div>
								</xsl:when>
								<xsl:otherwise>&nbsp;</xsl:otherwise>
							</xsl:choose>
						</div>
					</div>
				</div>
				
			</xsl:otherwise>
		</xsl:choose>
	
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
					<xsl:call-template name="account_sidebar" />
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

				<xsl:call-template name="brief_results" />
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

    <!-- old version of the new template GS -->
    <xsl:template name="old_status_sidebar">
        <h2>Libraries Searched</h2>
        <xsl:for-each select="//bytarget/target">
        <h3><xsl:value-of select="./title_short" /></h3>
        <ul id="status-{./name}">
            <xsl:variable name="fc">
                <xsl:choose>
                    <xsl:when test="./state='Client_Working'">
                        <xsl:text>yellow</xsl:text>
                    </xsl:when>
                    <xsl:when test="./state='Client_Idle'">
                        <xsl:text>green</xsl:text>
                    </xsl:when>
                    <xsl:when test="./state='Client_Disconnected'">
                        <xsl:text>red</xsl:text>
                        </xsl:when>
                    <xsl:otherwise></xsl:otherwise>
                </xsl:choose>
            </xsl:variable>
            <li>State: <span class="status-state" style="color: {$fc}"><xsl:value-of select="substring(./state, 8)" /></span></li>
            <li>Fetched/Found 
                <span class="status-records"><xsl:value-of select="./records" /></span>&nbsp;/&nbsp;
                <span class="status-hits"><xsl:value-of select="./hits" /></span>
            </li>
            <!-- <li>Diagnostic: <span class="status-diagnostic"><xsl:value-of select="./diagnostic" /></span></li> -->
        </ul>
        </xsl:for-each>
    </xsl:template>

    <!-- and the new template GS -->
    <xsl:template name="status_sidebar">
        <h2>Libraries Searched</h2>
        <h3>Records fetched / found</h3>
        <ul>
            <xsl:for-each select="//bytarget/target">
                <xsl:variable name="fc">
                    <xsl:choose>
                        <xsl:when test="./state='Client_Working'">
                            <xsl:text>working</xsl:text>
                        </xsl:when>
                        <xsl:when test="./state='Client_Idle'">
                            <xsl:text>succeeded</xsl:text>
                        </xsl:when>
                        <xsl:when test="./state='Client_Disconnected'">
                            <xsl:text>failed</xsl:text>
                        </xsl:when>
                        <xsl:otherwise></xsl:otherwise>
                    </xsl:choose>
                </xsl:variable>
                <li id="status-{./name}"><xsl:value-of select="./title_short" />
                    <xsl:text>: </xsl:text>
                    <span class="{$fc}">
                    <xsl:choose>
                        <xsl:when test="$fc = 'failed'">
                            <xsl:value-of select="substring(./state, 8)"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:choose>
                                <xsl:when test="./records = ./hits">
                                    <span class="status-records"><xsl:value-of select="./records" /></span>
                                    <span class="status-hits"></span>
                                </xsl:when>
                                <xsl:otherwise>
                                    <span class="status-records"><xsl:value-of select="./records" /></span>
                                    <span class="status-hits">&nbsp;/&nbsp;<xsl:value-of select="./hits" /></span>
                                </xsl:otherwise>
                            </xsl:choose>
                        </xsl:otherwise>
                    </xsl:choose>
                    </span>
                </li>
            </xsl:for-each>
        </ul>
    </xsl:template>

    <!-- TEMPLATE: FACET OPTION -->
    <!-- Overrides version in ../search/results.xsl to alter link GS -->

    <xsl:template name="facet_option"> 
        <li> 
            <xsl:choose> 
                <xsl:when test="url"> 
                    <a href="{url}"><xsl:value-of select="name" /></a> 
                </xsl:when> 
                <xsl:otherwise> 
                    <xsl:value-of select="name" /> 
                </xsl:otherwise> 
            </xsl:choose> 
            <xsl:if test="count"> &nbsp;(<xsl:value-of select="count" />) </xsl:if> 
         </li> 
     </xsl:template> 

</xsl:stylesheet>
