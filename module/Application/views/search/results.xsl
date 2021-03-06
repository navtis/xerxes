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
 copyright: 2011 California State University
 version: $Id$
 package: Xerxes
 link: http://xerxes.calstate.edu
 license: http://www.gnu.org/licenses/
 
 -->

<xsl:stylesheet version="1.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:php="http://php.net/xsl" exclude-result-prefixes="php">
		
	<!--
		TEMPLATE: SEARCH BREADCRUMB
	-->
	
	<xsl:template name="breadcrumb_search">

		<xsl:call-template name="breadcrumb_start" />
	
		<a href="{//request/controller}">
			<xsl:value-of select="$text_search_module" />
		</a>
		
		<xsl:value-of select="$text_breadcrumb_separator" />
		
	</xsl:template>
	
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
		
		<xsl:choose>
			<xsl:when test="not(results/total) or results/total = '0'">
				<xsl:call-template name="no_hits" />
			</xsl:when>
			<xsl:otherwise>
		
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
								
						<xsl:call-template name="search_recommendations" />
				
						<xsl:call-template name="brief_results" />
		
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
				
			</xsl:otherwise>
		</xsl:choose>
		
	</xsl:template>

	<!--
		TEMPLATE: SORT BAR
	-->

	<xsl:template name="sort_bar">	
	
		<div id="sort">
			<div class="yui-g" style="width: 100%">
				<div class="yui-u first">
					<xsl:copy-of select="$text_metasearch_results_summary" />
				</div>
				<div class="yui-u">
					<xsl:choose>
						<xsl:when test="//sort_display">
							<div id="sort-options" data-role="controlgroup" data-type="horizontal">
								<xsl:copy-of select="$text_results_sort_by" /><xsl:text>: </xsl:text>
								<xsl:for-each select="//sort_display/option">
									<xsl:choose>
										<xsl:when test="@active = 'true'">
											<strong data-role="button" data-theme="b"><xsl:value-of select="text()" /></strong>
										</xsl:when>
										<xsl:otherwise>
											<a href="{@link}" data-role="button">
												<xsl:value-of select="text()" />
											</a>
										</xsl:otherwise>
									</xsl:choose>
									<xsl:if test="following-sibling::option and $is_mobile = 0">
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

	
	</xsl:template>

	<!--
		TEMPLATE: NO HITS
	-->
	
	<xsl:template name="no_hits">
	
		<div class="no-hits error"><xsl:value-of select="$text_metasearch_hits_no_match" /></div>
	
	</xsl:template>
	
	<!--
		TEMPLATE: SEARCH BOX
	-->
	
	<xsl:template name="searchbox">
	
		<form action="{//request/controller}/search" method="get">
	
			<input type="hidden" name="lang" value="{//request/lang}" />
			
			<xsl:call-template name="searchbox_hidden_fields_local" />
	
			<xsl:if test="request/sort">
				<input type="hidden" name="sort" value="{request/sort}" />
			</xsl:if>
	
		<xsl:choose>
			<xsl:when test="$is_mobile = '1'">
				<xsl:call-template name="searchbox_mobile" />
			</xsl:when>
			<xsl:otherwise>
				<xsl:call-template name="searchbox_full" />
			</xsl:otherwise>
		</xsl:choose>
	
		</form>	
		
	</xsl:template>

	<!--
		TEMPLATE: SEARCH BOX MOBILE
	-->	
	
	<xsl:template name="searchbox_mobile">
	
		<xsl:variable name="search_query" select="//request/query" />
		<xsl:call-template name="mobile_search_box">
			<xsl:with-param name="query" select="$search_query" />
		</xsl:call-template>
			
	</xsl:template>

	<!-- 
		TEMPLATE: MOBILE SEARCH BOX
		Just the search box and go itself, suited for mobile
	-->
	
	<xsl:template name="mobile_search_box">
		<xsl:param name="query" />
		
		<xsl:if test="//request/action != 'results'">
		
			<div class="searchbox-mobile">
				<input type="text" name="query" value="{$query}" />
				<xsl:text> </xsl:text>
				<input class="submit_searchbox{$language_suffix}" type="submit" name="Submit" value="{$text_searchbox_go}" />
			</div>
			
		</xsl:if>
		
	</xsl:template>


	<!--
		TEMPLATE: SEARCH BOX FULL
	-->
	
	<xsl:template name="searchbox_full">
	
		<xsl:choose>
			<xsl:when test="request/advanced or request/advancedfull">
				<xsl:call-template name="advanced_search" />
			</xsl:when>
			<xsl:otherwise>
				<xsl:call-template name="simple_search" />			
			</xsl:otherwise>
		</xsl:choose>
	
	</xsl:template>

	<!--
		TEMPLATE: SIMPLE SEARCH
	-->
	
	<xsl:template name="simple_search">
	
		<xsl:variable name="query"	select="request/query" />
		
		<div class="raised-box search-box">
	
			<div class="search-label">
				<label for="field">Search</label><xsl:text> </xsl:text>
			</div>
			
			<div class="search-inputs">
	
				<select id="field" name="field">
					
					<xsl:for-each select="config/basic_search_fields/field">
					
						<xsl:variable name="internal">
							<xsl:choose>
								<xsl:when test="@id"><xsl:value-of select="@id" /></xsl:when>
								<xsl:otherwise><xsl:value-of select="@internal" /></xsl:otherwise>
							</xsl:choose>
						</xsl:variable>
					
						<option value="{$internal}">
						<xsl:if test="//request/field = $internal">
							<xsl:attribute name="selected">seleted</xsl:attribute>
						</xsl:if>
						<xsl:value-of select="@public" />
						</option>
						
					</xsl:for-each>
				</select>
				
				<xsl:text> </xsl:text><label for="query"><xsl:value-of select="$text_searchbox_for" /></label><xsl:text> </xsl:text>
				
				<input id="query" name="query" type="text" size="32" value="{$query}" /><xsl:text> </xsl:text>
				
				<input type="submit" name="Submit" value="GO" class="submit-searchbox{$language_suffix}" />
			
			</div>
			
			<xsl:if test="spelling/url">
				<p class="spell-suggest error">
					<xsl:value-of select="$text_searchbox_spelling_error" /><xsl:text> </xsl:text>
					<a href="{spelling/url}"><xsl:value-of select="spelling/query" /></a>
				</p>
			</xsl:if>	
			
			<xsl:call-template name="advanced_search_option" />
			
		</div>
	
	</xsl:template>
	
	<!-- 	
		TEMPLATE: TABS
		displays a tab configuration in the search architecture
	-->
	
	<xsl:template name="tabs">
		
		<xsl:if test="config/search">
		
			<div class="tabs">
				
				<xsl:for-each select="config/search">
						
					<ul id="tabnav">
						<xsl:call-template name="tab" />
					</ul>
					<div style="clear:both"></div>
				</xsl:for-each>
				
			</div>
		
		</xsl:if>
	</xsl:template>
	

	<!-- 
		TEMPLATE: TAB
		each tab
	-->
	
	<xsl:template name="tab">
	
		<xsl:for-each select="option">
			
			<li id="tab-{@id}">
				<xsl:if test="@current = 1">
					<xsl:attribute name="class">here</xsl:attribute>
				</xsl:if>
				
				<a href="{@url}">
					<xsl:value-of select="@public" />
					<xsl:text> </xsl:text>
					<xsl:call-template name="tab_hit" />
				</a>
			</li>
		</xsl:for-each>
		
	</xsl:template>

	<!-- 
		TEMPLATE: TAB HIT
	-->
	
	<xsl:template name="tab_hit">
	
		<span class="tabs-hit">
			<xsl:choose>
				<xsl:when test="@hits">
					(<xsl:value-of select="@hits" />)
				</xsl:when>
				<xsl:otherwise>
					<span class="tabs-hit-number" id="tab-{@id}-{@source}"></span>
				</xsl:otherwise>
			</xsl:choose>								
		</span>
	
	</xsl:template>
	
	<!-- 
		TEMPLATE: PAGING NAVIGATION
		Provides the visual display for moving through a set of results
	-->
	
	<xsl:template name="paging_navigation">
	
		<xsl:if test="//pager/page">
		
			<xsl:choose>
				
				<xsl:when test="$is_mobile = 1 and //pager/page[@type='next']">
				
					<a href="{//pager/page[@type='next']/@link}" data-role="button">
						<xsl:copy-of select="$text_results_next" />
					</a>
				
				</xsl:when>
					
				<xsl:otherwise>	
					<div class="results-pager">
			
						<ul class="results-pager-list">
						<xsl:for-each select="//pager/page">
							<li>
							<xsl:variable name="link" select="@link" />
							<xsl:choose>
								<xsl:when test="@here = 'true'">
									<strong><xsl:value-of select="text()" /></strong>
								</xsl:when>
								<xsl:otherwise>
									<a href="{$link}">
										<xsl:choose>
											<xsl:when test="@type = 'next'">
												<xsl:attribute name="class">results-pager-next</xsl:attribute>
												<xsl:copy-of select="$text_results_next" />
											</xsl:when>
											<xsl:otherwise>
												<xsl:attribute name="class">results-pager-link</xsl:attribute>
											</xsl:otherwise>
										</xsl:choose>
										<xsl:call-template name="text_results_sort_options">
											<xsl:with-param name="option" select="text()" />
										</xsl:call-template>
									</a>
								</xsl:otherwise>
							</xsl:choose>
							</li>
						</xsl:for-each>
						</ul>
					</div>
					
				</xsl:otherwise>
				
			</xsl:choose>
			
		</xsl:if>
	
	</xsl:template>
	
	<!-- 
		TEMPLATE: SEARCH SIDEBAR 
		the sidebar within the search results
	-->
	
	<xsl:template name="search_sidebar">
			
		<xsl:if test="//facets/groups">
		
			<div class="box">
			
				<h2>Narrow your results</h2>
				
				<xsl:for-each select="//facets/groups/group">
		
					<h3><xsl:value-of select="public" /></h3>
					
					<!-- only show first 10, unless there is 12 or fewer, in which case show all 12 -->
					
					<ul>
					<xsl:for-each select="facets/facet[position() &lt;= 10 or count(../facet) &lt;= 12]">
						<xsl:call-template name="facet_option" />
					</xsl:for-each>
					</ul>
					
					<xsl:if test="count(facets/facet) &gt; 12">
						
						<p id="facet-more-{name}" class="facet-option-more"> 
							[ <a id="facet-more-link-{name}" href="#" class="facet-more-option"> 
								<xsl:value-of select="count(facets/facet[position() &gt; 10])" /> more
							</a> ] 
						</p>
						
						<ul id="facet-list-{name}" class="facet-list-more">
							<xsl:for-each select="facets/facet[position() &gt; 10]">
								<xsl:call-template name="facet_option" />
							</xsl:for-each>
						</ul>
						
						<p id="facet-less-{name}" class="facet-option-less"> 
							[ <a id="facet-less-link-{name}" href="#" class="facet-less-option"> 
								show less
							</a> ] 
						</p>
	
					</xsl:if>
		
				</xsl:for-each>
			</div>
			
			<xsl:call-template name="sidebar_additional" />
		
		</xsl:if>
	
	</xsl:template>
	
	<!-- TEMPLATE: FACET OPTION -->
	
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
						
			<xsl:if test="count">			
				&nbsp;(<xsl:value-of select="count" />)
			</xsl:if>
		</li>
	
	</xsl:template>

	<!-- 
		TEMPLATE: FACETS APPLIED
		A bar across the top of the results showing a limit has been applied
	-->
	
	<xsl:template name="facets_applied">
		
		<xsl:if test="query/limits">
			<div class="results-facets-applied">
				<ul>
					<xsl:for-each select="query/limits/limit">
						<li>
							<div class="remove">
								<a href="{remove_url}">
									<xsl:call-template name="img_facet_remove">
										<xsl:with-param name="alt">remove limit</xsl:with-param>
									</xsl:call-template>
								</a>
							</div> 
							Limited to: <xsl:value-of select="value" /> 
						</li>
					</xsl:for-each>
				</ul>
			</div>
		</xsl:if>
		
	</xsl:template>	

	<!-- 
		TEMPLATE: BRIEF RESULTS
	-->
	
	<xsl:template name="brief_results">
	
		<ul id="results" data-role="listview" data-inset="true">
		
		<xsl:for-each select="//records/record/xerxes_record">

			<xsl:call-template name="brief_result" />

		</xsl:for-each>
		
		</ul>
		
	</xsl:template>
	
	<!-- 
		TEMPLATE: BRIEF RESULT
		display of results geared toward articles (or really any non-book display)
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
			
				<div class="results-type">
				
					<!-- format -->
				
					<xsl:call-template name="text_results_format">
						<xsl:with-param name="format" select="format/public" />
					</xsl:call-template>
					
					<!-- language note -->
					
					<xsl:call-template name="text_results_language" />
					
					<!-- peer reviewed -->
					
					<xsl:if test="refereed">
						<xsl:text> </xsl:text><xsl:call-template name="img_refereed" />
						<xsl:text> </xsl:text><xsl:copy-of select="$text_results_refereed" />
					</xsl:if>
				</div>
				
				<!-- abstract -->
				
				<div class="results-abstract">
				
					<xsl:choose>
						<xsl:when test="summary_type = 'toc'">
							<xsl:value-of select="$text_record_summary_toc" /><xsl:text>: </xsl:text>
						</xsl:when>
						<xsl:when test="summary_type = 'subjects'">
							<xsl:value-of select="$text_record_summary_subjects" /><xsl:text>: </xsl:text>
						</xsl:when>					
					</xsl:choose>
				
					<xsl:choose>
						<xsl:when test="string-length(summary) &gt; 300">
							<xsl:value-of select="substring(summary, 1, 300)" /> . . .
						</xsl:when>
						<xsl:when test="summary">
							<xsl:value-of select="summary" />
						</xsl:when>
						
					</xsl:choose>
				</div>
				
				<!-- primary author -->
                <!-- FIXME local SEARCH25 changes GS - FIXME -->
				<xsl:choose>
				    <xsl:when test="primary_author">
					    <span class="results-author">
						    <strong><xsl:copy-of select="$text_results_author" />: </strong><xsl:value-of select="primary_author" />
					    </span>
                    </xsl:when>
				    <xsl:when test="responsible">
					    <span class="results-author">
						    <strong><xsl:copy-of select="$text_results_author" />: </strong><xsl:value-of select="responsible" />
					    </span>
                    </xsl:when>
				</xsl:choose>
				
				<!-- publication year -->
				
				<xsl:if test="year">
					<span class="results-year">
						<strong><xsl:copy-of select="$text_results_year" />: </strong>
						<xsl:value-of select="year" />
					</span>
				</xsl:if>
				
				<!-- journal info -->
				
				<xsl:if test="journal or journal_title">
					<span class="results-publishing">
						<strong><xsl:copy-of select="$text_results_published_in" />: </strong>
						<xsl:choose>
							<xsl:when test="journal_title">
								<xsl:value-of select="journal_title" />
							</xsl:when>
							<xsl:otherwise>
								<xsl:value-of select="journal" />
							</xsl:otherwise>
						</xsl:choose>
					</span>
				</xsl:if>
				
				<!-- custom area for local implementatin to add junk -->
				
				<xsl:call-template name="additional_brief_record_data" />
				
				<div class="record-actions">
					
					<!-- full text -->
					
					<xsl:call-template name="full_text_options" />
					
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

	<!-- 
		TEMPLATE: FULL TEXT OPTIONS
		Logic for determining which full-text links to show
	-->
	
	<xsl:template name="full_text_options">
		<xsl:param name="show_full_text_and_link_resolver">false</xsl:param> 
					
		<xsl:variable name="link_resolver_allowed">
			<xsl:choose>
				<xsl:when test="../dont_show_link_resolver or (full_text_bool and $show_full_text_and_link_resolver = 'false')">
					<xsl:text>false</xsl:text>
				</xsl:when>
				<xsl:otherwise>
					<xsl:text>true</xsl:text>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
				
		<!-- native full-text -->
	
		<xsl:if test="full_text_bool">
			
			<xsl:call-template name="full_text_links"/>							
				
		</xsl:if>
		
		<!-- link resolver -->
		
		<xsl:if test="../url_open">
		
			<xsl:choose>
				
				<!-- link resolver, full-text predetermined -->
				
				<xsl:when test="$link_resolver_allowed = 'true' and subscription = 1">
						<a href="{../url_open}&amp;fulltext=1" target="{$link_target}" class="record-action link-resolver-link">
							<xsl:call-template name="img_format_html">
								<xsl:with-param name="class">mini-icon link-resolver-link</xsl:with-param>
							</xsl:call-template>
							<xsl:text> </xsl:text>
							<xsl:copy-of select="$text_link_resolver_available" />
						</a>
				</xsl:when>
				
				<!-- link resolver, no full-text predetermined -->
				
				<xsl:when test="$link_resolver_allowed = 'true'">
						<a href="{../url_open}" target="{$link_target}" class="record-action link-resover-link">
							<img src="{$image_sfx}" alt="" class="mini-icon link-resover-link "/>
							<xsl:text> </xsl:text>
							<xsl:copy-of select="$text_link_resolver_check" />
						</a>
				</xsl:when>
				
				<!-- if no direct link or link resolver, do we have an original record link? -->
				
				<xsl:when test="links/link[@type='original_record'] and ../show_original_record_link">
					<xsl:call-template name="record_link">
						<xsl:with-param name="type">original_record</xsl:with-param>
						<xsl:with-param name="text" select="$text_link_original_record"/>
						<xsl:with-param name="img_src" select="$img_src_chain"/>
					</xsl:call-template>
				</xsl:when>
				
			</xsl:choose>
			
		</xsl:if>
		
	</xsl:template>

	<!-- 
		TEMPLATE: SAVE RECORD
		Display for saving (and also deleting) a record
	-->

	<xsl:template name="save_record">

		<xsl:variable name="source" select="source" />
		<xsl:variable name="record_id" select="record_id" />
		
		<!-- @todo: move this to the controller? -->
		
		<xsl:variable name="is_already_saved" select="//request/session/resultssaved[@key = $record_id]" />
	
		<div id="save-record-option-{$source}-{$record_id}" class="record-action save-record-action">
			
			<xsl:call-template name="img_save_record">
				<xsl:with-param name="id" select="concat('folder-', $source, '-', $record_id)" />
				<xsl:with-param name="class">mini-icon save-record-link</xsl:with-param>
				<xsl:with-param name="test" select="$is_already_saved" />
			</xsl:call-template>
						
			<xsl:text> </xsl:text>	
			
			<a id="link-{$source}-{$record_id}" href="{../url_save_delete}" class="save-record">				
				
				<!-- 'saved' class used as a tag by ajaxy stuff -->
				<xsl:if test="$is_already_saved">
					<xsl:attribute name="class">saved</xsl:attribute>
				</xsl:if>
							
				<xsl:choose>
					<xsl:when test="$is_already_saved">
						<xsl:choose>
							<xsl:when test="//session/role = 'named'">
								<xsl:copy-of select="$text_results_record_saved" />
							</xsl:when>
							<xsl:otherwise>
								<xsl:copy-of select="$text_results_record_saved_temp" />
							</xsl:otherwise>
						</xsl:choose>
					</xsl:when>
					<xsl:otherwise><xsl:copy-of select="$text_results_record_save_it" /></xsl:otherwise>
				</xsl:choose>
			</a>
			
			<!-- temporary save note -->
			<xsl:if test="$is_already_saved and //request/session/role != 'named'"> 
				 <span class="temporary-login-note">
					(<xsl:text> </xsl:text><a href="{//navbar/element[@id = 'login']/url}">
						<xsl:copy-of select="$text_results_record_saved_perm" />
					</a><xsl:text> </xsl:text>)
				</span>
			</xsl:if>
		</div>
		
		<!-- label/tag input for saved records, if record is saved and it's not a temporary session -->
		
		<!-- @todo bring this back
		
		<xsl:if test="$is_already_saved and $temporarySession != 'true'">
			<div id="label-{$source}-{$record_id}"> 
				<xsl:call-template name="tag_input">
					<xsl:with-param name="record" select="//saved_records/saved[@id = $record_id]" />
					<xsl:with-param name="context">the results page</xsl:with-param>
				</xsl:call-template>	
			</div>
		</xsl:if>
		
		-->
	
	</xsl:template>
	
	<!-- 
		TEMPLATE: HIDDEN TAG LAYERS
		These are used in the metasearch results (but not folder results because it already has some of these) 
		and record pages for the auto-complete tag input
	-->
	
	<xsl:template name="hidden_tag_layers">
		
		<div id="tag-suggestions" class="autocomplete" style="display:none;"></div>
	
		<div id="template-tag-input" class="results-label" style="display:none;">
			<xsl:call-template name="tag_input">
				<xsl:with-param name="id">template</xsl:with-param>
			</xsl:call-template> 
		</div>
	
		<div id="labels-master" class="folder-output" style="display: none">
			<xsl:call-template name="tags_display" />
		</div>
		
		<xsl:call-template name="safari_tag_fix" />
		
	</xsl:template>

	<!-- 
		TEMPLATE: SAFARI TAG FIX
		This hidden iframe essentially thwarts the Safari backforward cache so that
		tags don't get wacky
	-->
	
	<xsl:template name="safari_tag_fix">
		
		<xsl:if test="contains(//server/http_user_agent,'Safari')">
		
			<iframe style="height:0px;width:0px;visibility:hidden" src="about:blank">
				<!-- this frame prevents back-forward cache for safari -->
			</iframe>
			
		</xsl:if>
	
	</xsl:template>

	<!-- 
		TEMPLATE: TAGS DISPLAY
		used by a couple of pages in the folder area for displaying tags
	-->
	
	<xsl:template name="tags_display">
		
		<h2><xsl:copy-of select="$text_folder_options_tags" /></h2>
		<ul>
		<xsl:for-each select="tags/tag">
			<li>
			<xsl:choose>
				<xsl:when test="@label = //request/label">
					<strong><xsl:value-of select="@label" /></strong> ( <xsl:value-of select="@total" /> )
				</xsl:when>
				<xsl:otherwise>
					<a href="{@url}"><span class="label-list-item"><xsl:value-of select="@label" /></span></a> ( <xsl:value-of select="@total" /> )
				</xsl:otherwise>
			</xsl:choose>
			</li>
		</xsl:for-each>
		</ul>
		
	</xsl:template>


	<!--
		TEMPLATE: TAG INPUT
		tab/label input form used to enter labels/tags for saved record, on both folder page and search results
		page (for saved records only) one of record (usually) or id (unusually) are required. 
		parameter: record  =>  XSL node representing a savedRecord with a child <id> and optional children <tags>
		parameter: id => pass a string id instead of a record in nodeset. Used for the 'template' form for ajax 
		label input adder. 
	-->
	
	<xsl:template name="tag_input">
		<xsl:param name="record" select="." />
		<xsl:param name="id" select="$record/id" /> 
		<xsl:param name="context">the saved records page</xsl:param>
	
		<div class="folder-labels record-action" id="tag-input-div-{$id}">
			<form action="folder/tags_edit" method="get" class="tags">
			
				<!-- note that if this event is fired with ajax, the javascript changes
				the action element here to 'tags_edit_ajax' so the server knows to display a 
				different view, which the javascript captures and uses to updates the totals above. -->
				
				<input type="hidden" name="lang" value="{//request/lang}" />
				<input type="hidden" name="record" value="{$id}" />
				<input type="hidden" name="context" value="{$context}" />
				
				<xsl:variable name="tag_list">
					<xsl:for-each select="$record/tag">
						<xsl:value-of select="text()" />
						<xsl:if test="following-sibling::tag">
							<xsl:text>, </xsl:text>
						</xsl:if>
					</xsl:for-each>
				</xsl:variable>
				
				<input type="hidden" name="tags-shaddow" id="shadow-{$id}" value="{$tag_list}" />
				
				<label for="tags-{$id}"><xsl:copy-of select="$text_records_tags" /></label>
				
				<input type="text" name="tags" id="tags-{$id}" class="tags-input" value="{$tag_list}" />			
				<xsl:text> </xsl:text>
				<input id="submit-{$id}" type="submit" name="submit-button" value="Update" class="tags-submit{$language_suffix}" />
			</form>
		</div>
		
	</xsl:template>

	<!--
		TEMPLATE: FULL TEXT LINKS
	-->
	
	<xsl:template name="full_text_links">
				
		<xsl:for-each select="links/link[@type = 'full']">
			
			<div class="record-action {@type}">
								
				<a href="{url}" target="{$link_target}">
				
					<xsl:choose>
						<xsl:when test="@format = 'pdf'">
							<xsl:call-template name="img_format_pdf">
								<xsl:with-param name="class">mini-icon full-text-link pdf</xsl:with-param>
							</xsl:call-template>
							<xsl:text> </xsl:text>
							<xsl:choose>
								<xsl:when test="display != ''">
									<xsl:value-of select="display" />
								</xsl:when>
								<xsl:otherwise>
									<xsl:copy-of select="$text_records_fulltext_pdf" />
								</xsl:otherwise>
							</xsl:choose>
						</xsl:when>
						<xsl:when test="@format = 'html'">
							<xsl:call-template name="img_format_html">
								<xsl:with-param name="class">mini-icon full-text-link html</xsl:with-param>
							</xsl:call-template>
							<xsl:text> </xsl:text>
							<xsl:choose>
								<xsl:when test="display != ''">
									<xsl:value-of select="display" />
								</xsl:when>
								<xsl:otherwise>
									<xsl:copy-of select="$text_records_fulltext_html" />
								</xsl:otherwise>
							</xsl:choose>
						</xsl:when>
						<xsl:otherwise>
							<xsl:call-template name="img_format_unknown">
								<xsl:with-param name="class">mini-icon full-text-link unknown</xsl:with-param>
							</xsl:call-template>
							<xsl:text> </xsl:text>
							<xsl:choose>
								<xsl:when test="display != ''">
									<xsl:value-of select="display" />
								</xsl:when>
								<xsl:otherwise>
									<xsl:copy-of select="$text_records_fulltext_available" />
								</xsl:otherwise>
							</xsl:choose>
						</xsl:otherwise>
					</xsl:choose>
				</a>
			
			</div>
			
		</xsl:for-each>
		
	</xsl:template>

	<!-- search box fields overriden in templates -->
	
	<xsl:template name="advanced_search_option" />
	<xsl:template name="advanced_search" />
	<xsl:template name="searchbox_hidden_fields_local" />
	
	<!-- additional record data overriden in templates -->
	
	<xsl:template name="additional_record_links" />
	<xsl:template name="additional_brief_record_data" />
	
	<!-- search results templates -->
	
	<xsl:template name="search_recommendations" />
	
</xsl:stylesheet>
