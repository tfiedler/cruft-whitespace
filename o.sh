#!/bin/bash
ENSCRIPT=$(which enscript)
MKPDF=$(which pstopdf)
OPTS=

[ ! $1 ] && 
{

    echo "Usage: <STREAM> | $(basename $0) outfile.pdf "
    exit 1
}

#${ENSCRIPT} -G -H -u"AWI" -f "Times-Roman12" -t"Oracle Maintenance / Saturday October 18, 2008" -o - | ${MKPDF} -p -i -o $1
${ENSCRIPT} -G -H -u"AWI" -f "Times-Roman12" -t"<some oddball title>" -o - | ${MKPDF} -p -i -o $1
RC=$?

exit ${RC}
