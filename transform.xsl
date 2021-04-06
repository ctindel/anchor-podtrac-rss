<xsl:stylesheet
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    version="1.0">

    <xsl:output method="xml" indent="yes"/>

    <xsl:template match="node()|@*">
        <xsl:copy>
            <xsl:apply-templates select="node()|@*"/>
        </xsl:copy>
    </xsl:template>

    <xsl:template match="/rss/channel/item/enclosure">
        <xsl:copy>
            <xsl:attribute name="url">
                <xsl:text>https://dts.podtrac.com/redirect.m4a/</xsl:text>
                <xsl:value-of select="substring-after(@url, 'https://')"/>
            </xsl:attribute>
            <xsl:apply-templates select="@*[not(local-name()='url')]|node()"/>
        </xsl:copy>
    </xsl:template>
</xsl:stylesheet>
