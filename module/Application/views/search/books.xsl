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
		TEMPLATE: MODULE HEADER
		add the book css and javascript to the header
	-->	
	
	<xsl:template name="module_header">
	
		<link href="css/books.css?xerxes_version={$xerxes_version}" rel="stylesheet" type="text/css" />
	
	</xsl:template>

	<!-- 
		TEMPLATE: RECORD BASIC. Position of Image changed to allow float GS
	-->

	<xsl:template name="record_basic">

			<!-- Title -->
	    <h1><xsl:call-template name="record_title" /></h1>
	
        <div id="book-record">
	
		    <div id="book-record-book-cover">
			    <xsl:call-template name="book_jacket_full">
				    <xsl:with-param name="isbn" select="standard_numbers/isbn[string-length(text()) = 10]" />
			    </xsl:call-template>
		    </div>
			
			<!-- Basic record information (Author, Year, Format, Database, ...) -->
			
			<xsl:call-template name="record_summary" />
			
			<!-- google javascript lookup -->
			
			<xsl:call-template name="google_preview" />
		</div>
		
		<div style="clear:both"></div>
							
		<!-- A box with actions for current record (get full-text, link to holdings, save record) -->
		
		<xsl:call-template name="record_actions" />
		
		<!-- Umlaut stuff -->
		
		<xsl:call-template name="umlaut" />
	
		<!-- Detailed record information (Summary, Topics, Standard numbers, ...) -->
		
		<xsl:call-template name="record_details" />
				
	</xsl:template>	

	<!--
		TEMPLATE: RECORD ACTIONS
	-->	
	
	<xsl:template name="record_actions">
		<div id="record-full-text" class="raised-box record-actions">
			
			<xsl:call-template name="availability">
				<xsl:with-param name="context">record</xsl:with-param>
			</xsl:call-template>			

			<xsl:call-template name="save_record" />
			
		</div>
	</xsl:template>

	<!-- 
		TEMPLATE: BRIEF RESULTS
		override and choose book
	-->

	<xsl:template name="brief_results">
	
		<ul id="results">
		
		<xsl:for-each select="//records/record/xerxes_record">

			<xsl:call-template name="brief_result_book" />

		</xsl:for-each>
		
		</ul>
		
	</xsl:template>
	
	<!-- 
		TEMPLATE: BRIEF RESULT
		special template for the display of books & media
	-->

	<xsl:template name="brief_result_book">
				
		<xsl:variable name="isbn" 		select="standard_numbers/isbn[string-length(text()) = 10]" />
		<xsl:variable name="oclc" 		select="standard_numbers/oclc" />
		<xsl:variable name="year" 		select="year" />
				
		<xsl:variable name="display" select="//config/lookup_display" />
		
		<li class="result">
		
			<div class="book-cover">
				<xsl:call-template name="book_jacket_brief">
					<xsl:with-param name="isbn" select="$isbn" />
				</xsl:call-template>
			</div>
		
			<div class="book-result">
				
				<!-- title -->
				
				<div class="results-title">
					<a href="{../url}" class="results-title">
						
						<xsl:value-of select="title_normalized" />
						
						<!-- conference or corporate name at end to distinguish annual reports, etc. -->
						
						<xsl:if test="authors/author[@type='conference' or @type='corporate' and not(@additional)]">
							<xsl:text> / </xsl:text>
							<xsl:value-of select="authors/author[@type='conference' or @type='corporate' and not(@additional)]/aucorp" />
						</xsl:if>
						
					</a>
				</div>
				
				<div class="results-info">
					
					<!-- format -->
					
					<div class="results-type">
						<xsl:value-of select="format/public" />
					</div>
					
					<!-- abstract -->
	
					<div class="results-abstract">
					
						<xsl:if test="abstract">
							<div class="book-abstract-data">
								<xsl:choose>
									<xsl:when test="string-length(abstract) &gt; 300">
										<xsl:value-of select="substring(summary, 1, 300)" /> . . .
									</xsl:when>
									<xsl:otherwise>
										<xsl:value-of select="abstract" />
									</xsl:otherwise>
								</xsl:choose>
							</div>
						</xsl:if>
					
                        <!-- FIXME author chunk rewritten for pz2 -->
                        
							<div class="results-book-summary">
								<xsl:if test="format/internal != 'JFULL'">
								
									<!-- author -->
						            <xsl:if test="primary_author">
									    <xsl:copy-of select="$text_results_author" />: <xsl:value-of select="primary_author" /><br />
                                    </xsl:if>
						            <xsl:if test="responsible">
									    <xsl:value-of select="responsible" /><br />
                                    </xsl:if>
								
									<!-- publication info -->
								
									<xsl:if test="publisher">
										<xsl:if test="place">
											<xsl:value-of select="place" />
											<xsl:text>: </xsl:text>									
										</xsl:if>
										<xsl:value-of select="publisher" />
										<xsl:if test="year">
											<xsl:text>, </xsl:text>
											<xsl:value-of select="year" />
										</xsl:if>
									</xsl:if>
						
								</xsl:if>								
							</div>				
						
					</div>
					
					<div class="record-actions">
						
						<!-- availability -->
						
						<xsl:call-template name="availability">
							<xsl:with-param name="type" select="//config/lookup_display" />
						</xsl:call-template>
						
						<!-- save record -->
		
						<xsl:call-template name="save_record" />
						
					</div>
					<div style="clear:both"></div>	
					
				</div>
			</div>
		</li>
	
	</xsl:template>

	<!-- 
		TEMPLATE: BOOK JACKET FULL
	-->
	
	<xsl:template name="book_jacket_full">
		<xsl:param name="isbn" />
		<img src="http://images.amazon.com/images/P/{$isbn}.01.jpg" alt="" class="book-jacket-large" />
	</xsl:template>

	<!-- 
		TEMPLATE: BOOK JACKET BRIEF
	-->
	
	<xsl:template name="book_jacket_brief">
		<xsl:param name="isbn" />
		<img src="http://images.amazon.com/images/P/{$isbn}.01.THUMBZZZ.jpg" alt="" class="book-jacket" />
	</xsl:template>
	
	<!-- 
		TEMPLATE: AVAILABILITY
	-->
	
	<xsl:template name="availability">
		<xsl:param name="context">results</xsl:param>
		<xsl:param name="type" />
		<xsl:call-template name="availability_lookup">
			<xsl:with-param name="record_id" select="record_id" />
			<xsl:with-param name="context" select="$context" />
			<xsl:with-param name="type" select="$type" />
		</xsl:call-template>
	
	</xsl:template>	
	
	
	<!-- 	
		TEMPLATE: AVAILABILITY LOOKUP
	-->
	
	<xsl:template name="availability_lookup">
		<xsl:param name="record_id" />
		<xsl:param name="isbn" />
		<xsl:param name="oclc" />
		<xsl:param name="type" select="'none'" />
		<xsl:param name="nosave" />
		<xsl:param name="context">results</xsl:param>
			
		<xsl:variable name="source" select="//request/source" />
		
		<xsl:variable name="printAvailable" select="count(../holdings/holding/items/item)" />
		<xsl:variable name="onlineCopies" select="count(links/link[@type != 'none'])" />
		<xsl:variable name="totalCopies" select="$printAvailable + $onlineCopies" />

		<xsl:choose>
		
			<xsl:when test="//config/lookup">
			
				<xsl:choose>		
					<xsl:when test="../holdings/checked">
										
						<!-- item and holdings data already fetched and in the XML response -->
					
						<!-- pick display type -->
					
						<xsl:choose>
						
							<xsl:when test="../holdings/holdings">
							
								<xsl:call-template name="availability_lookup_holdings">
									<xsl:with-param name="context" select="$context" />
								</xsl:call-template>
								
							</xsl:when>
							
							<xsl:when test="$type = 'summary'">
							
								<xsl:call-template name="availability_lookup_summary">
									<xsl:with-param name="totalCopies" select="$totalCopies" />
									<xsl:with-param name="printAvailable" select="$printAvailable" />
								</xsl:call-template> 
								
							</xsl:when>
							<xsl:otherwise>
							
								<xsl:call-template name="availability_lookup_full">
									<xsl:with-param name="totalCopies" select="$totalCopies" />
								</xsl:call-template>
							
							</xsl:otherwise>
						</xsl:choose>
					
					</xsl:when>
		
					<!-- not here, so need to get it dynamically with ajax -->
			
					<xsl:otherwise>
								
						<div id="{//request/controller}-{$record_id}-{$type}" class="availability-load"></div>
			
					</xsl:otherwise>				
				</xsl:choose>
	
				<!-- check for full-text -->
				
				<xsl:call-template name="full_text_links"/>	
								
			</xsl:when>
			
			<!-- no lookup required, thanks -->
			
			<xsl:otherwise>
				<xsl:call-template name="availability_lookup_none" />	
			</xsl:otherwise>
		</xsl:choose>
	
	</xsl:template>
	
	<!-- 	
		TEMPLATE: NO LOOKUP
		For sources that have no look-up enabled
	-->
	
	<xsl:template name="availability_lookup_none">
		
		<xsl:call-template name="ill_option" />	
			
	</xsl:template>
	
	<!-- 	
		TEMPLATE: AVAILABILITY LOOKUP SUMMARY
		A summary view of the holdings information
	-->
	
	<xsl:template name="availability_lookup_summary">
		<xsl:param name="totalCopies" />
		<xsl:param name="printAvailable" />	
		
		<xsl:choose>
			<xsl:when test="../holdings/items/item and $printAvailable = '0'">
			
				<div class="record-action books-availability-missing">
					<xsl:call-template name="img_book_not_available">
						<xsl:with-param name="class">mini-icon</xsl:with-param>
					</xsl:call-template>
					No Copies Available
				</div>
				
				<div class="record-action">
					<xsl:call-template name="ill_option" />
				</div>
	
			</xsl:when>
			<xsl:otherwise>
			
				<div class="record-action">
				
					<xsl:choose>
						<xsl:when test="$printAvailable = '1'">
							<xsl:call-template name="img_holdings">
								<xsl:with-param name="class">mini-icon</xsl:with-param>
							</xsl:call-template> 
							<xsl:text> </xsl:text>
							1 copy available
						</xsl:when>
						<xsl:when test="$printAvailable &gt; '1'">
							<xsl:call-template name="img_holdings">
									<xsl:with-param name="class">mini-icon</xsl:with-param>
							</xsl:call-template> 
							<xsl:text> </xsl:text>
							<xsl:value-of select="$printAvailable" /> copies available
						</xsl:when>	
					</xsl:choose>
				
				</div>
				
			</xsl:otherwise>		
		</xsl:choose>
		
	</xsl:template>
	
	<!-- 	
		TEMPLATE: AVAILABILITY LOOKUP HOLDINGS
		Display of holdings data for things like journals and newspapers
	-->
	
	<xsl:template name="availability_lookup_holdings">
		
		<xsl:param name="context">record</xsl:param>
	
		
		<xsl:if test="links">
	
			<p><strong>Online</strong></p>
			
			<xsl:call-template name="full_text_links"/>
			
		</xsl:if>
		
		<xsl:if test="../holdings/holdings">
	
			<p><strong>Print holdings</strong></p>
		
			<xsl:for-each select="../holdings/holdings/holding">
				<ul class="holdings-summary-statement">
					<xsl:for-each select="data">
						<li><xsl:value-of select="@key" />: <xsl:value-of select="@value" /></li>
					</xsl:for-each>
				</ul>
			</xsl:for-each>
			
		</xsl:if>
	
		<xsl:if test="$context = 'record'">
		
			<xsl:if test="../holdings/items/item">
		
				<p><strong><xsl:value-of select="$temp_text_bound_volumes" /></strong></p>					
				<xsl:call-template name="availability_item_table" />
				
			</xsl:if>
		
		</xsl:if>
	</xsl:template>
	
	
	<!-- 	
		TEMPLATE: AVAILABILITY LOOKUP FULL
		A full table-view of the (print) holdings information, with full-text below
	-->
	
	<xsl:template name="availability_lookup_full">
		<xsl:param name="totalCopies" />
	
		<xsl:if test="count(../holdings/items/item) != '0'">
			<xsl:call-template name="availability_item_table" />
		</xsl:if>
		
		<xsl:if test="$totalCopies = 0">
			<xsl:call-template name="ill_option" />
		</xsl:if>
				
	</xsl:template>
	
	<!-- 	
		TEMPLATE: AVAILABILITY ITEM TABLE
		Show the items in a table
	-->
	
	<xsl:template name="availability_item_table">
	
		<div>
			<xsl:attribute name="class">
				<xsl:text>booksAvailable</xsl:text>
				<xsl:if test="//request/action = 'record'">
					<xsl:text> booksAvailableRecord</xsl:text>
				</xsl:if>
			</xsl:attribute>
			
			<table class="holdings-table">
			<tr>
				<xsl:if test="../holdings/items/item/institution">
					<th>Institution</th>
				</xsl:if>
				<th>Location</th>
				<th>Call Number</th>
				<th>Status</th>
			</tr>
			<xsl:for-each select="../holdings/items/item">
				<tr>
					<xsl:if test="institution">
						<td><xsl:value-of select="institution" /></td>
					</xsl:if>
					<td><xsl:value-of select="location" /></td>
					<td><xsl:value-of select="callnumber" /></td>
					<td><xsl:value-of select="status" /></td>
				</tr>
			</xsl:for-each>
			</table>
		</div>
	
	</xsl:template>
	
	<!-- 	
		TEMPLATE: ILL OPTION
		just the ill link on a holdings lookup
	-->
	
	<xsl:template name="ill_option">
			
		<xsl:variable name="source"  select="//request/source"/>	
		
		<xsl:if test="count(../holdings/items/item)">
		
			<xsl:if test="../url_open">
		
				<div class="results-availability">
					<a target="{$link_target}" href="{../url_open}" class="record-action">
						<img src="{$image_sfx}" alt="" border="0" class="mini-icon link-resolver-link "/>
						<xsl:text> </xsl:text>
						<xsl:copy-of select="$text_link_resolver_check" /> 
					</a>
				</div>
				
			</xsl:if>
			
		</xsl:if>
			
	</xsl:template>	

	<!-- 	
		TEMPLATE: SMS OPTION
	-->

	<xsl:template name="sms_option">
		
		<xsl:if test="count(../holdings/items/item) &gt; 0">
		
			<div id="sms-option" class="results-availability record-action">
	
				<xsl:call-template name="img_phone" />
				<xsl:text> </xsl:text>
				<a id="sms-link" href="{../url_sms}">Send location to your phone</a> 
			
			</div>
			
			<div id="sms" style="display:none">
				<xsl:call-template name="sms">
					<xsl:with-param name="header">h2</xsl:with-param>
				</xsl:call-template>
			</div>
	
		</xsl:if>
	
	</xsl:template>

	<!-- 	
		TEMPLATE: SMS
	-->
	
	<xsl:template name="sms">
		<xsl:param name="header">h1</xsl:param>
		
		<xsl:variable name="num_copies" select="count(//holdings/items/item)" />
			
		<xsl:element name="{$header}">
			Send title and location to your mobile phone
		</xsl:element>
	
		<form name="smsForm" action="folder/sms" method="get">
		
			<input type="hidden" name="lang" value="{//request/lang}" />
			<input type="hidden" name="title" value="{title_normalized}" />
			
			<div class="sms-property">
				<label for="phone">Your phone number: </label>
			</div>
			<div class="sms-value">
				<input type="text" name="phone" id="phone" />
			</div>
			
			<div class="sms-property">
				<label for="provider">Provider:</label>
			</div>
			<div class="sms-value">
				<select name="provider">
					<option value="">-- choose one --</option>
					
					<xsl:call-template name="sms_input_option">
						<xsl:with-param name="email">txt.att.net</xsl:with-param>
						<xsl:with-param name="text">AT&amp;T / Cingular</xsl:with-param>
					</xsl:call-template>
	
					<xsl:call-template name="sms_input_option">
						<xsl:with-param name="email">MyMetroPcs.com</xsl:with-param>
						<xsl:with-param name="text">Metro PCS</xsl:with-param>
					</xsl:call-template>
	
					<xsl:call-template name="sms_input_option">
						<xsl:with-param name="email">messaging.nextel.com</xsl:with-param>
						<xsl:with-param name="text">Nextel</xsl:with-param>
					</xsl:call-template>
	
					<xsl:call-template name="sms_input_option">
						<xsl:with-param name="email">messaging.sprintpcs.com</xsl:with-param>
						<xsl:with-param name="text">Sprint</xsl:with-param>
					</xsl:call-template>
	
					<xsl:call-template name="sms_input_option">
						<xsl:with-param name="email">tmomail.net</xsl:with-param>
						<xsl:with-param name="text">T-Mobile</xsl:with-param>
					</xsl:call-template>
	
					<xsl:call-template name="sms_input_option">
						<xsl:with-param name="email">vtext.com</xsl:with-param>
						<xsl:with-param name="text">Verizon</xsl:with-param>
					</xsl:call-template>
	
					<xsl:call-template name="sms_input_option">
						<xsl:with-param name="email">vmobl.com</xsl:with-param>
						<xsl:with-param name="text">Virgin</xsl:with-param>
					</xsl:call-template>
					
					<!--
					
					<option value="message.alltel.com">Alltel</option>
					<option value="ptel.net">Powertel</option>
					<option value="tms.suncom.com">SunCom</option>
					<option value="email.uscc.net">US Cellular</option>
					
					-->
					
				</select>
			</div>
	
			<xsl:if test="$num_copies &gt; 1">
				<h3>Choose one of the copies</h3>
			</xsl:if>
							
			<xsl:for-each select="../holdings/items/item">
				
				<xsl:variable name="item">
					<xsl:value-of select="location" />
					<xsl:text> </xsl:text>
					<xsl:value-of select="callnumber" />
				</xsl:variable>
				
				<label>
					<xsl:if test="$num_copies &gt; 1">
						<xsl:attribute name="class">sms-copy</xsl:attribute>
					</xsl:if>
					
					<input name="item" value="{$item}">
						<xsl:attribute name="type">
							<xsl:choose>
								<xsl:when test="$num_copies &gt; 1">radio</xsl:when>
								<xsl:otherwise>hidden</xsl:otherwise>
							</xsl:choose>
						</xsl:attribute>
						<xsl:if test="position() = 1">
							<xsl:attribute name="checked">checked</xsl:attribute>
						</xsl:if>
					</input>
					<xsl:if test="$num_copies &gt; 1">
						<xsl:text> </xsl:text>
						<xsl:value-of select="$item" />
						<br />
					</xsl:if>
				</label>
				
			</xsl:for-each>
			
			<br />
			
			<input type="submit" value="Send" class="submit-send{$language_suffix}" />
			
			<p class="sms-note">Carrier charges may apply.</p>
			
		</form>
	
	</xsl:template>

	<!-- 	
		TEMPLATE: SMS INPUT OPTION
	-->
	
	<xsl:template name="sms_input_option">
		<xsl:param name="email" />
		<xsl:param name="text" />
		
		<option value="{$email}">
			<xsl:if test="//request/session/user_provider = $email">
				<xsl:attribute name="selected">selected</xsl:attribute>
			</xsl:if>
			<xsl:value-of select="$text" />
		</option>
	
	</xsl:template>

	<!-- 	
		TEMPLATE: GOOGLE PREVIEW
	-->
	
	<xsl:template name="google_preview">
	
		<xsl:variable name="isbn" select="//results/records/record/xerxes_record/standard_numbers/isbn" />
	
		<xsl:variable name="ids">
			<xsl:for-each select="//results/records/record/xerxes_record/standard_numbers/isbn|standard_numbers/oclc">
				<xsl:choose>
					<xsl:when test="name() = 'isbn'">
						<xsl:text>'ISBN:</xsl:text><xsl:value-of select="text()" /><xsl:text>'</xsl:text>
					</xsl:when>
					<xsl:when test="name() = 'oclc'">
						<xsl:text>'OCLC:</xsl:text><xsl:value-of select="text()" /><xsl:text>'</xsl:text>
					</xsl:when>
				</xsl:choose>
				<xsl:if test="following-sibling::isbn|following-sibling::oclc">
					<xsl:text>,</xsl:text>
				</xsl:if>
			</xsl:for-each>
		
		</xsl:variable>
		
		<div class="google-preview">
			<script type="text/javascript" src="http://books.google.com/books/previewlib.js"></script>
			<script type="text/javascript">GBS_insertPreviewButtonPopup([<xsl:value-of select="$ids" />]);</script>
			<noscript><a href="http://books.google.com/books?as_isbn={$isbn}">Check for more information at Google Book Search</a></noscript>
		</div>
	
	</xsl:template>
	
	
</xsl:stylesheet>
