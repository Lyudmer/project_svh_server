<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl='http://www.w3.org/1999/XSL/Transform' xmlns:SInWs="Sum-In_Words.uri" version='1.0' exclude-result-prefixes='SInWs'>
	<xsl:output method='xml'/>
	
	<xsl:template name="ValidInnCee">
		<xsl:param name="INN"/>
		<xsl:variable name="N1" select="number(substring($INN,1,1))"/>
		<xsl:variable name="N2" select="number(substring($INN,2,1))"/>
		<xsl:variable name="N3" select="number(substring($INN,3,1))"/>
		<xsl:variable name="N4" select="number(substring($INN,4,1))"/>
		<xsl:variable name="N5" select="number(substring($INN,5,1))"/>
		<xsl:variable name="N6" select="number(substring($INN,6,1))"/>
		<xsl:variable name="N7" select="number(substring($INN,7,1))"/>
		<xsl:variable name="N8" select="number(substring($INN,8,1))"/>
		<xsl:variable name="N9" select="number(substring($INN,9,1))"/>
		<xsl:variable name="N10" select="number(substring($INN,10,1))"/>
		<xsl:variable name="N11" select="number(substring($INN,11,1))"/>
		<xsl:choose>
			<xsl:when test="number($INN)">
				<xsl:choose>
					<xsl:when test="string-length($INN)=10">
						<xsl:variable name="Nsum" select="(($N1 * 2+$N2 * 4+$N3 * 10+$N4 * 3+$N5 * 5+$N6 * 9+$N7 * 4+$N8 * 6+$N9 * 8) mod 11) mod 10"/>
						<xsl:choose>
							<xsl:when test="(number(substring($INN,10,1))=$Nsum)">0</xsl:when>
							<xsl:otherwise>1</xsl:otherwise>
						</xsl:choose>
					</xsl:when>
					<xsl:when test="string-length($INN)=12">
						<xsl:variable name="Nsum1" select="($N1 * 7+$N2 * 2+$N3 * 4+$N4 * 10+$N5 * 3+$N6 * 5+$N7 * 9+$N8 * 4+$N9 * 6+$N10 * 8) mod 11"/>
						<xsl:variable name="Nsum2" select="($N1 * 3+$N2 * 7+$N3 * 2+$N4 * 4+$N5 * 10+$N6 * 3+$N7 * 5+$N8 * 9+$N9 * 4+$N10 * 6+$N11 * 8) mod 11"/>
						<xsl:variable name="K1Sum">
							<xsl:choose>
								<xsl:when test="$Nsum1 >9">
									<xsl:value-of select="$Nsum1 mod 10"/>
								</xsl:when>
								<xsl:otherwise>
									<xsl:value-of select="$Nsum1"/>
								</xsl:otherwise>
							</xsl:choose>
						</xsl:variable>
						<xsl:variable name="K2Sum">
							<xsl:choose>
								<xsl:when test="$Nsum2>9">
									<xsl:value-of select="$Nsum2 mod 10"/>
								</xsl:when>
								<xsl:otherwise>
									<xsl:value-of select="$Nsum2"/>
								</xsl:otherwise>
							</xsl:choose>
						</xsl:variable>
						<xsl:choose>
							<xsl:when test="(number(substring($INN,11,1))=number($K1Sum) and number(substring($INN,12,1))=number($K2Sum))">0</xsl:when>
							<xsl:otherwise>1</xsl:otherwise>
						</xsl:choose>
					</xsl:when>
					<xsl:otherwise>1</xsl:otherwise>
				</xsl:choose>
			</xsl:when>
			<xsl:otherwise>1</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	<xsl:template name="ValidContainerNum">
		<xsl:param name="Nums"/>
		<xsl:param name="notSea"/>
		<xsl:variable name="Sing0" select="string-length($Nums)&lt;18"/>
		<xsl:variable name="Sing1" select="substring($Nums,1,4)"/>
		<xsl:variable name="Sing2" select="substring($Nums,5)"/>
		<xsl:variable name="Sing11" select="contains(translate($Sing1,'QWERTYUIOPLKJHGFDSAZXCVBNM','AAAAAAAAAAAAAAAAAAAAAAAAA'),'A')"/>
		<xsl:variable name="Sing21">
			<xsl:choose>
				<xsl:when test="number($Sing2)=$Sing2 and contains(translate($Sing2,'0123456789', '9999999999'),'9')">1</xsl:when>
				<xsl:otherwise>0</xsl:otherwise>
			</xsl:choose> 
		</xsl:variable> 
		<xsl:choose>
			<xsl:when test="$Sing0 and $Sing11 and number($Sing21)=1">
				<xsl:choose>
					<xsl:when test="$notSea=1">
						<xsl:variable name="NumSRC">
							<xsl:call-template name="ValidContainerNumSRC">
								<xsl:with-param name="Nums" select="$Nums"/>
							</xsl:call-template>
						</xsl:variable>
						<xsl:value-of select="$NumSRC"/>
					</xsl:when>
					<xsl:otherwise>1</xsl:otherwise>
				</xsl:choose>
			</xsl:when>
			<xsl:otherwise>0</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	<xsl:variable name='Self' select='document("")'/>
	<xsl:template name='SumInWords'>
		<xsl:param name="Sum"/>
		<xsl:call-template name='RecurseSumWords'>
			<xsl:with-param name='Value' select='$Sum'/>
		</xsl:call-template>
	</xsl:template>

	<xsl:template name='RecurseSumWords'>
		<xsl:param name="Value" select="''"/>
		<xsl:param name="En"/>
		<xsl:choose>
			<xsl:when test='($Value div 1000000) - (($Value mod 1000000) div 1000000) > 0'>
				<xsl:call-template name='DecodeInteger'>
					<xsl:with-param name='Value' select='($Value div 1000000) - (($Value mod 1000000) div 1000000)'/>
					<xsl:with-param name='controlbad' select='0'/>
					<xsl:with-param name="En" select="$En"/>
				</xsl:call-template>
				<xsl:call-template name='GetWordType'>
					<xsl:with-param name='Value' select='($Value div 1000000) - (($Value mod 1000000) div 1000000)'/>
					<xsl:with-param name='tagName'>
						<xsl:choose>
							<xsl:when test="$En='1'">
								<xsl:value-of select="'SInWs:BillionEn'"/>
							</xsl:when>
							<xsl:otherwise>
								<xsl:value-of select="'SInWs:Billion'"/>
							</xsl:otherwise>
						</xsl:choose>
					</xsl:with-param> 
				</xsl:call-template>
				<xsl:call-template name='RecurseSumWords'>
					<xsl:with-param name='Value' select='$Value mod 1000000'/>
					<xsl:with-param name="En" select="$En"/>
				</xsl:call-template>
			</xsl:when>
			<xsl:when test='($Value div 1000) - (($Value mod 1000) div 1000) > 0'>
				<xsl:call-template name='DecodeInteger'>
					<xsl:with-param name='Value' select='($Value div 1000) - (($Value mod 1000) div 1000)'/>
					<xsl:with-param name='controlbad' select='1'/>
					<xsl:with-param name="En" select="$En"/>
				</xsl:call-template>
				<xsl:call-template name='GetWordType'>
					<xsl:with-param name='Value' select='($Value div 1000) - (($Value mod 1000) div 1000)'/>
					<xsl:with-param name='tagName'>
						<xsl:choose>
							<xsl:when test="$En='1'">
								<xsl:value-of select="'SInWs:ThousandEn'"/>
							</xsl:when>
							<xsl:otherwise>
								<xsl:value-of select="'SInWs:Thousand'"/>
							</xsl:otherwise>
						</xsl:choose>
					</xsl:with-param> 
				</xsl:call-template>
				<xsl:call-template name='RecurseSumWords'>
					<xsl:with-param name='Value' select='$Value mod 1000'/>
					<xsl:with-param name="En" select="$En"/>
				</xsl:call-template>
			</xsl:when>
			<xsl:when test='$Value != 0'>
				<xsl:call-template name='DecodeInteger'>
					<xsl:with-param name='Value' select='$Value'/>
					<xsl:with-param name='controlbad' select='0'/>
					<xsl:with-param name="En" select="$En"/>
				</xsl:call-template>
			</xsl:when>
		</xsl:choose>
	</xsl:template>

	<xsl:template name='DecodeInteger'>
		<xsl:param name='Value' select="''"/>
		<xsl:param name='controlbad' select="''"/>
		<xsl:param name="En"/>
		<xsl:variable name='Value100' select='$Value mod 100'/>
		<xsl:if test='($Value div 100) - ($Value100 div 100) != 0'>
			<xsl:call-template name='GetWordData'>
				<xsl:with-param name='Pos' select='27 + (($Value div 100) - ($Value100 div 100))'/>
				<xsl:with-param name='tagName'>
					<xsl:choose>
						<xsl:when test="$En='1'">
							<xsl:value-of select="'SInWs:WordsEn'"/>
						</xsl:when>
						<xsl:otherwise>
							<xsl:value-of select="'SInWs:Words'"/>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:with-param> 
			</xsl:call-template>
		</xsl:if>
		<xsl:choose>
			<xsl:when test='$Value100 > 20'>
				<xsl:call-template name='GetWordData'>
					<xsl:with-param name='Pos' select='18 + (($Value100 div 10) - (($Value100 mod 10) div 10))'/>
					<xsl:with-param name='tagName'>
						<xsl:choose>
							<xsl:when test="$En='1'">
								<xsl:value-of select="'SInWs:WordsEn'"/>
							</xsl:when>
							<xsl:otherwise>
								<xsl:value-of select="'SInWs:Words'"/>
							</xsl:otherwise>
						</xsl:choose>
					</xsl:with-param> 
				</xsl:call-template>
				<xsl:if test='$Value100 mod 10 != 0'>
					<xsl:call-template name='GetSmallWord'>
						<xsl:with-param name='Value' select='$Value100 mod 10'/>
						<xsl:with-param name='controlbad' select='$controlbad'/>
						<xsl:with-param name="En" select="$En"/>
					</xsl:call-template>
				</xsl:if>
			</xsl:when>
			<xsl:when test='$Value100 != 0'>
				<xsl:call-template name='GetSmallWord'>
					<xsl:with-param name='Value' select='$Value100'/>
					<xsl:with-param name='controlbad' select='$controlbad'/>
					<xsl:with-param name="En" select="$En"/>
				</xsl:call-template>
			</xsl:when>
		</xsl:choose>
	</xsl:template>

	<xsl:template name='GetSmallWord'>
		<xsl:param name='Value' select="''"/>
		<xsl:param name='controlbad' select="''"/>
		<xsl:param name="En"/>
		<xsl:choose>
			<xsl:when test='($controlbad = 1) and ($Value &lt; 3)'>
				<xsl:call-template name='GetWordData'>
					<xsl:with-param name='Pos' select='$Value'/>
					<xsl:with-param name='tagName'>
						<xsl:choose>
							<xsl:when test="$En='1'">
								<xsl:value-of select="'SInWs:BadWordEn'"/>
							</xsl:when>
							<xsl:otherwise>
								<xsl:value-of select="'SInWs:BadWord'"/>
							</xsl:otherwise>
						</xsl:choose>
					</xsl:with-param> 
				</xsl:call-template>
			</xsl:when>
			<xsl:otherwise>
				<xsl:call-template name='GetWordData'>
					<xsl:with-param name='Pos' select='$Value'/>
					<xsl:with-param name='tagName'>
						<xsl:choose>
							<xsl:when test="$En='1'">
								<xsl:value-of select="'SInWs:WordsEn'"/>
							</xsl:when>
							<xsl:otherwise>
								<xsl:value-of select="'SInWs:Words'"/>
							</xsl:otherwise>
						</xsl:choose>
					</xsl:with-param> 
				</xsl:call-template>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template name='GetWordType'>
		<xsl:param name='Value' select="''"/>
		<xsl:param name='tagName' select="''"/>
		<xsl:choose>
			<xsl:when test='($Value mod 100) > 20'>
				<xsl:call-template name='GetInnerType'>
					<xsl:with-param name='Value' select='($Value mod 100) mod 10'/>
					<xsl:with-param name='tagName' select='$tagName'/>
				</xsl:call-template>
			</xsl:when>
			<xsl:otherwise>
				<xsl:call-template name='GetInnerType'>
					<xsl:with-param name='Value' select='$Value mod 100'/>
					<xsl:with-param name='tagName' select='$tagName'/>
				</xsl:call-template>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template name='GetInnerType'>
		<xsl:param name='Value' select="''"/>
		<xsl:param name='tagName' select="''"/>
		<xsl:choose>
			<xsl:when test='$Value = 1'>
				<xsl:call-template name='GetWordData'>
					<xsl:with-param name='Pos' select='1'/>
					<xsl:with-param name='tagName' select='$tagName'/>
				</xsl:call-template>
			</xsl:when>
			<xsl:when test='$Value > 1 and $Value &lt; 5'>
				<xsl:call-template name='GetWordData'>
					<xsl:with-param name='Pos' select='2'/>
					<xsl:with-param name='tagName' select='$tagName'/>
				</xsl:call-template>
			</xsl:when>
			<xsl:otherwise>
				<xsl:call-template name='GetWordData'>
					<xsl:with-param name='Pos' select='3'/>
					<xsl:with-param name='tagName' select='$tagName'/>
				</xsl:call-template>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	
	<xsl:template name='GetWordData'>
		<xsl:param name='Pos' select="''"/>
		<xsl:param name='tagName' select="''"/>
		<xsl:for-each select='$Self//SInWs:*[name() = $tagName]'>
			<xsl:if test='position() = $Pos'>
				<xsl:value-of select="./@word"/>
				<xsl:text> </xsl:text>
			</xsl:if>
		</xsl:for-each>
	</xsl:template>

	<SInWs:Billion word='МИЛЛИОН'/>
	<SInWs:Billion word='МИЛЛИОНА'/>
	<SInWs:Billion word='МИЛЛИОНОВ'/>
	<SInWs:Thousand word='ТЫСЯЧА'/>
	<SInWs:Thousand word='ТЫСЯЧИ'/>
	<SInWs:Thousand word='ТЫСЯЧ'/>
	<SInWs:BadWord word='ОДНА'/>
	<SInWs:BadWord word='ДВЕ'/>
	<SInWs:Words word='ОДИН'/>
	<SInWs:Words word ='ДВА'/>
	<SInWs:Words word='ТРИ'/>
	<SInWs:Words word='ЧЕТЫРЕ'/>
	<SInWs:Words word='ПЯТЬ'/>
	<SInWs:Words word='ШЕСТЬ'/>
	<SInWs:Words word='СЕМЬ'/>
	<SInWs:Words word='ВОСЕМЬ'/>
	<SInWs:Words word='ДЕВЯТЬ'/>
	<SInWs:Words word='ДЕСЯТЬ'/>
	<SInWs:Words word='ОДИННАДЦАТЬ'/>
	<SInWs:Words word='ДВЕНАДЦАТЬ'/>
	<SInWs:Words word='ТРИНАДЦАТЬ'/>
	<SInWs:Words word='ЧЕТЫРНАДЦАТЬ'/>
	<SInWs:Words word='ПЯТНАДЦАТЬ'/>
	<SInWs:Words word='ШЕСТНАДЦАТЬ'/>
	<SInWs:Words word='СЕМНАДЦАТЬ'/>
	<SInWs:Words word='ВОСЕМНАДЦАТЬ'/>
	<SInWs:Words word='ДЕВЯТНАДЦАТЬ'/>
	<SInWs:Words word='ДВАДЦАТЬ'/>
	<SInWs:Words word='ТРИДЦАТЬ'/>
	<SInWs:Words word='СОРОК'/>
	<SInWs:Words word='ПЯТЬДЕСЯТ'/>
	<SInWs:Words word='ШЕСТЬДЕСЯТ'/>
	<SInWs:Words word='СЕМЬДЕСЯТ'/>
	<SInWs:Words word='ВОСЕМЬДЕСЯТ'/>
	<SInWs:Words word='ДЕВЯНОСТО'/>
	<SInWs:Words word='СТО'/>
	<SInWs:Words word='ДВЕСТИ'/>
	<SInWs:Words word='ТРИСТА'/>
	<SInWs:Words word='ЧЕТЫРЕСТА'/>
	<SInWs:Words word='ПЯТЬСОТ'/>
	<SInWs:Words word='ШЕСТЬСОТ'/>
	<SInWs:Words word='СЕМЬСОТ'/>
	<SInWs:Words word='ВОСЕМЬСОТ'/>
	<SInWs:Words word='ДЕВЯТЬСОТ'/>
	
	<SInWs:BillionEn word='MILLION'/>			
	<SInWs:BillionEn word='MILLIONS'/>
	<SInWs:BillionEn word='MILLIONS'/>
	<SInWs:ThousandEn word='THOUSAND'/>
	<SInWs:ThousandEn word='THOUSANDS'/>
	<SInWs:ThousandEn word='THOUSANDS'/>
	<SInWs:BadWordEn word='ONE'/>
	<SInWs:BadWordEn word='TWO'/>
	<SInWs:WordsEn word='ONE'/>
	<SInWs:WordsEn word ='TWO'/>
	<SInWs:WordsEn word='THREE'/>
	<SInWs:WordsEn word='FOUR'/>
	<SInWs:WordsEn word='FIVE'/>
	<SInWs:WordsEn word='SIX'/>
	<SInWs:WordsEn word='SEVEN'/>
	<SInWs:WordsEn word='EIGHT'/>
	<SInWs:WordsEn word='NINE'/>
	<SInWs:WordsEn word='TEN'/>
	<SInWs:WordsEn word='ELEVEN'/>
	<SInWs:WordsEn word='TWELVE'/>
	<SInWs:WordsEn word='THIRTEEN'/>
	<SInWs:WordsEn word='FOURTEEN'/>
	<SInWs:WordsEn word='FIFTEEN'/>
	<SInWs:WordsEn word='SIXTEEN'/>
	<SInWs:WordsEn word='SEVENTEEN'/>
	<SInWs:WordsEn word='EIGHTEEN'/>
	<SInWs:WordsEn word='NINETEEN'/>
	<SInWs:WordsEn word='TWENTY'/>
	<SInWs:WordsEn word='THIRTY'/>
	<SInWs:WordsEn word='FORTY'/>
	<SInWs:WordsEn word='FIFTY'/>
	<SInWs:WordsEn word='SIXTY'/>
	<SInWs:WordsEn word='SEVENTY'/>
	<SInWs:WordsEn word='EIGHTY'/>
	<SInWs:WordsEn word='NINETY'/>
	<SInWs:WordsEn word='ONE HUNDRED'/>
	<SInWs:WordsEn word='TWO HUNDRED'/>
	<SInWs:WordsEn word='THREE HUNDRED'/>
	<SInWs:WordsEn word='FOUR HUNDRED'/>
	<SInWs:WordsEn word='FIVE HUNDRED'/>
	<SInWs:WordsEn word='SIX HUNDRED'/>
	<SInWs:WordsEn word='SEVEN HUNDRED'/>
	<SInWs:WordsEn word='EIGHT HUNDRED'/>
	<SInWs:WordsEn word='NINE HUNDRED'/>
	
	
	<xsl:template name='ValidContainerNumSRC'>
		<xsl:param name="Nums"/>
		<xsl:variable name="Simb1Src" select="substring($Nums,11,1)"/>	
		<xsl:variable name="SimbNumSrc">	
			<xsl:call-template name='SumSRC'>
				<xsl:with-param name='SimbNum' select='substring($Nums,1,10)'/>
				<xsl:with-param name='SumSrcR' select='0'/>
				<xsl:with-param name='PosSimb' select='1'/>
			</xsl:call-template>
		</xsl:variable>
		<xsl:choose>
			<xsl:when test="number($Simb1Src)=number($SimbNumSrc)">1</xsl:when>
			<xsl:otherwise>0</xsl:otherwise>
		</xsl:choose>
	</xsl:template>	
	<xsl:template name='SumSRC'>
		<xsl:param name='SimbNum'/>
		<xsl:param name='SumSrcR'/>
		<xsl:param name='PosSimb'/>
		<xsl:choose>
			<xsl:when test="string-length($SimbNum)>0">
				<xsl:variable name="Simb1" select="normalize-space(substring($SimbNum,1,1))"/>
				<xsl:variable name="Simb1Code">
					<xsl:choose>
						<xsl:when test="number($Simb1)=$Simb1">
							<xsl:value-of select="$Simb1"/>
						</xsl:when>
						<xsl:otherwise>
							<xsl:value-of select="$Self//SInWs:Lettes[@word=$Simb1]/@code"/>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:variable>

				<xsl:variable name="PosCode" select="$Self//SInWs:NumPos[@word=$PosSimb]/@code"/>
				<xsl:variable name="Simb1Sum" select="number($SumSrcR)+number($Simb1Code) * number($PosCode)"/>
			
				<xsl:call-template name='SumSRC'>
					<xsl:with-param name='SimbNum' select='substring($SimbNum,2)'/>
					<xsl:with-param name='SumSrcR' select='$Simb1Sum'/>
					<xsl:with-param name='PosSimb' select='number($PosSimb)+1'/>
				</xsl:call-template>
			</xsl:when>
			<xsl:otherwise>
				<xsl:variable name="RezS" select="number($SumSrcR) mod 11"/>
				<xsl:variable name="RezS1">
					<xsl:choose>
						<xsl:when test="number($RezS)=10">0</xsl:when>
						<xsl:otherwise>
							<xsl:value-of select="$RezS"/>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:variable>
				<xsl:value-of select="$RezS1"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	
	<SInWs:Lettes word="A" code='10'/>
	<SInWs:Lettes word="B" code='12'/>
	<SInWs:Lettes word="C" code='13'/>
	<SInWs:Lettes word="D" code='14'/>
	<SInWs:Lettes word="E" code='15'/>
	<SInWs:Lettes word="F" code="16"/>
	<SInWs:Lettes word="G" code='17'/>
	<SInWs:Lettes word="H" code='18'/>
	<SInWs:Lettes word="I" code='19'/>
	<SInWs:Lettes word="J" code='20'/>
	<SInWs:Lettes word="K" code='21'/>
	<SInWs:Lettes word="L" code='23'/>
	<SInWs:Lettes word="M" code='24'/>
	<SInWs:Lettes word="N" code='25'/>
	<SInWs:Lettes word="O" code='26'/>
	<SInWs:Lettes word="P" code='27'/>
	<SInWs:Lettes word="Q" code='28'/>
	<SInWs:Lettes word="R" code='29'/>
	<SInWs:Lettes word="S" code='30'/>
	<SInWs:Lettes word="T" code='31'/>
	<SInWs:Lettes word="U" code='32'/>
	<SInWs:Lettes word="V" code='34'/>
	<SInWs:Lettes word="W" code='35'/>
	<SInWs:Lettes word="X" code='36'/>
	<SInWs:Lettes word="Y" code='37'/>
	<SInWs:Lettes word="Z" code='38'/>

	<SInWs:NumPos word="1" code='1'/>
	<SInWs:NumPos word="2" code='2'/>
	<SInWs:NumPos word="3" code='4'/>
	<SInWs:NumPos word="4" code='8'/>
	<SInWs:NumPos word="5" code='16'/>
	<SInWs:NumPos word="6" code='32'/>
	<SInWs:NumPos word="7" code='64'/>
	<SInWs:NumPos word="8" code='128'/>
	<SInWs:NumPos word="9" code='256'/>
	<SInWs:NumPos word="10" code='512'/>
</xsl:stylesheet>
	
	
