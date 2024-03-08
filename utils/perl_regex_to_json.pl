#!/usr/bin/perl

# usage:  cat a.txt | ./perl_regex_to_json.pl



# https://stackoverflow.com/a/21092679/1749293
use utf8;

# https://stackoverflow.com/a/627672/1749293
# use open qw/:std :utf8/;

# https://stackoverflow.com/a/519359/1749293
use strict;
use warnings;
use open qw(:std :utf8);

my $numOfArgs = $#ARGV + 1;
print "thanks, you gave me $numOfArgs command-line arguments.\n";

# print "############## arguments are:\n";
# foreach my $arg (@ARGV) {
#     print $arg, "\n";
# }


# print "############## original stdin text:\n";
# while (<>) {
#     print $_; # or simply "print;"
# }

# print "############## original stdin text:\n";
# foreach my $line ( <STDIN> ) {
#     chomp( $line );
#     print "$line\n";
# }


my $content = "";
# while (<>) {
#     $content = $content . $_;
# }
while(<>){
    my @chars = split //, $_;
    $content = $content . "$_" foreach(@chars);
}





print "\n____________________________________ contents before replacing ____________________________________\n";
print "$content\n";

# $content = <<"EOF";
# {msg: success, code: 200, data: {records: [{headImg: null, code: 00005e000009999999999999, name: 未知, mobile: 13600000000, carSeries: TeslaModelS, experienceWilling: 1分, buyWilling: 未知, customerClueFollowupEmpProfileId: 710099, customerOppFollowupEmpProfileId: 0, customerClueFollowupEmpProfileName: 杨幂, customerOppFollowupEmpProfileName: null, customerLastFollowupTime: 2024-03-06 18:06:12, customerLastFollowupContent: 老子被店长自动分配至杨幂, branchName: 香港九龙动漫园, customerCreateTime: 2024-03-06 17:50:29, smartRegisterSource: unknown, smartLiveness: 0, customerStage: lead, customerStatus: 待跟进, leadId: c633FDSFAF3333EEEEed, oppId: , leadStatus: 待跟进, oppStatus: , oppExperienceWilling: null, oppBuyWilling: null, oppLastFollowupDate: null, oppLastFollowupContent: null, updateTime: 2024-03-06 18:06:12, createTime: 2024-03-06 17:50:29, shopCode: XXOOII8899, shopName: 香港九龙动漫园, campaignName: TeslaModelS春节红包07AI清洗意向老子, insideSalesEmpProfileName: null, insideSalesManagerEmpProfileName: null, returnVisitIsName: null, insideSalesGroupName: , insideSalesGroupType: , customerCampaignName: TeslaModelS春节红包07AI清洗意向老子, locateArea: 天京省小城市, customerFirstChannelName: 线上渠道, needHighLight: false, customerSecondChannelCode: qdB019, customerSecondChannelName: 官方渠道(私域), customerThirdChannelName: 私域用户促活, sinceLastFollowUpTime: 0天, lastTryTime: 1970-01-01 08:00:00, tempLossTime: 1970-01-01 08:00:00, description: , channelSort: 100, preShopCode: XXOOII8899, preShopName: 香港九龙动漫园, activateFlag: 1, activateType: customer_online, customerRelation: 0, customerFlags: null, isTransferCustomer: 0, lastDistributeTime: 1970-01-01 08:00:00, transferCustomerExpiredTime: null, nextFollowTime: null, isTransferCustomerExpired: null}, {headImg: null, code: c6333333EEEEed, name: 未知, mobile: 18406400124, carSeries: TeslaModelS, experienceWilling: 1分, buyWilling: 未知, customerClueFollowupEmpProfileId: 710099, customerOppFollowupEmpProfileId: 0, customerClueFollowupEmpProfileName: 杨幂, customerOppFollowupEmpProfileName: null, customerLastFollowupTime: 2024-03-06 18:06:10, customerLastFollowupContent: 老子被店长自动分配至杨幂, branchName: 香港九龙动漫园, customerCreateTime: 2024-03-06 17:50:41, smartRegisterSource: unknown, smartLiveness: 0, customerStage: lead, customerStatus: 待跟进, leadId: l7788787866666666e, oppId: , leadStatus: 待跟进, oppStatus: , oppExperienceWilling: null, oppBuyWilling: null, oppLastFollowupDate: null, oppLastFollowupContent: null, updateTime: 2024-03-06 18:06:10, createTime: 2024-03-06 17:50:41, shopCode: XXOOII8899, shopName: 香港九龙动漫园, campaignName: TeslaModelS春节红包07AI清洗意向老子, insideSalesEmpProfileName: null, insideSalesManagerEmpProfileName: null, returnVisitIsName: null, insideSalesGroupName: , insideSalesGroupType: , customerCampaignName: TeslaModelS春节红包07AI清洗意向老子, locateArea: 天京省小城市, customerFirstChannelName: 线上渠道, needHighLight: false, customerSecondChannelCode: qdB019, customerSecondChannelName: 官方渠道(私域), customerThirdChannelName: 私域用户促活, sinceLastFollowUpTime: 0天, lastTryTime: 1970-01-01 08:00:00, tempLossTime: 2024-03-06 18:01:02, description: , channelSort: 100, preShopCode: XXOOII8899, preShopName: 香港九龙动漫园, activateFlag: 1, activateType: customer_online, customerRelation: 0, customerFlags: null, isTransferCustomer: 0, lastDistributeTime: 1970-01-01 08:00:00, transferCustomerExpiredTime: null, nextFollowTime: null, isTransferCustomerExpired: null}, {headImg: null, code: cAFDAFDSAFASFSAFASFDSAf3, name: 未知, mobile: 15110420821, carSeries: TeslaModelS, experienceWilling: 1分, buyWilling: 未知, customerClueFollowupEmpProfileId: 710099, customerOppFollowupEmpProfileId: 0, customerClueFollowupEmpProfileName: 杨幂, customerOppFollowupEmpProfileName: null, customerLastFollowupTime: 2024-03-06 18:05:59, customerLastFollowupContent: 老子被店长自动分配至杨幂, branchName: 香港九龙动漫园, customerCreateTime: 2024-03-06 17:50:42, smartRegisterSource: unknown, smartLiveness: 0, customerStage: lead, customerStatus: 待跟进, leadId: l65e83c71e4b09f23ad1fbcf4, oppId: , leadStatus: 待跟进, oppStatus: , oppExperienceWilling: null, oppBuyWilling: null, oppLastFollowupDate: null, oppLastFollowupContent: null, updateTime: 2024-03-06 18:05:59, createTime: 2024-03-06 17:50:42, shopCode: XXOOII8899, shopName: 香港九龙动漫园, campaignName: TeslaModelS春节红包07AI清洗意向老子, insideSalesEmpProfileName: null, insideSalesManagerEmpProfileName: null, returnVisitIsName: null, insideSalesGroupName: , insideSalesGroupType: , customerCampaignName: TeslaModelS春节红包07AI清洗意向老子, locateArea: 天京省小城市, customerFirstChannelName: 线上渠道, needHighLight: false, customerSecondChannelCode: qdB019, customerSecondChannelName: 官方渠道(私域), customerThirdChannelName: 私域用户促活, sinceLastFollowUpTime: 0天, lastTryTime: 1970-01-01 08:00:00, tempLossTime: 1970-01-01 08:00:00, description: , channelSort: 100, preShopCode: XXOOII8899, preShopName: 香港九龙动漫园, activateFlag: 1, activateType: customer_online, customerRelation: 0, customerFlags: null, isTransferCustomer: 0, lastDistributeTime: 1970-01-01 08:00:00, transferCustomerExpiredTime: null, nextFollowTime: null, isTransferCustomerExpired: null}, {headImg: null, code: c65e83c70e4b09f23ad1fbceb, name: 未知, mobile: 15364946344, carSeries: TeslaModelS, experienceWilling: 1分, buyWilling: 未知, customerClueFollowupEmpProfileId: 710099, customerOppFollowupEmpProfileId: 0, customerClueFollowupEmpProfileName: 杨幂, customerOppFollowupEmpProfileName: null, customerLastFollowupTime: 2024-03-06 18:05:57, customerLastFollowupContent: 老子被店长自动分配至杨幂, branchName: 香港九龙动漫园, customerCreateTime: 2024-03-06 17:50:41, smartRegisterSource: unknown, smartLiveness: 0, customerStage: lead, customerStatus: 待跟进, leadId: cAF4444444444, oppId: , leadStatus: 待跟进, oppStatus: , oppExperienceWilling: null, oppBuyWilling: null, oppLastFollowupDate: null, oppLastFollowupContent: null, updateTime: 2024-03-06 18:05:57, createTime: 2024-03-06 17:50:41, shopCode: XXOOII8899, shopName: 香港九龙动漫园, campaignName: TeslaModelS春节红包07AI清洗意向老子, insideSalesEmpProfileName: null, insideSalesManagerEmpProfileName: null, returnVisitIsName: null, insideSalesGroupName: , insideSalesGroupType: , customerCampaignName: TeslaModelS春节红包07AI清洗意向老子, locateArea: 天京省小城市, customerFirstChannelName: 线上渠道, needHighLight: false, customerSecondChannelCode: qdB019, customerSecondChannelName: 官方渠道(私域), customerThirdChannelName: 私域用户促活, sinceLastFollowUpTime: 0天, lastTryTime: 1970-01-01 08:00:00, tempLossTime: 1970-01-01 08:00:00, description: , channelSort: 100, preShopCode: XXOOII8899, preShopName: 香港九龙动漫园, activateFlag: 1, activateType: customer_online, customerRelation: 0, customerFlags: null, isTransferCustomer: 0, lastDistributeTime: 1970-01-01 08:00:00, transferCustomerExpiredTime: null, nextFollowTime: null, isTransferCustomerExpired: null}], total: 4, size: 10, current: 1, orders: [], optimizeCountSql: true, hitCount: false, countId: null, maxLimit: null, notShowPage: false, searchCount: true, pages: 1}, record: 00000000000000-99900000-88800000000, traceId: 0000000000000000000000000}
# EOF


# Add Double quotation marks >>>>

# replace key
$content =~ s/(\w+): /"$1": /g;

# replace value: date & time format
$content =~ s/(\d+-\d+-\d+ \d+:\d+:\d+)/"$1"/g;

# replace value: uuid or a hex string
$content =~ s/: ([\w|-]+)/: "$1"/g;

# replace value: the empty string
$content =~ s/": , "/": "", "/g;

# replace value: the string with brackets
$content =~ s/"(\(.*?\)),/$1",/g;


# Remove Double quotation marks >>>>
$content =~ s/"null"/null/g;
$content =~ s/"true"/true/g;
$content =~ s/"false"/false/g;
$content =~ s/"(\d+)"/$1/g;


print "\n____________________________________ contents after replacing ____________________________________\n";
print "$content\n";

