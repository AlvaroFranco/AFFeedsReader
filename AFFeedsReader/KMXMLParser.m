//
//  KMXMLParser.m
//  KMXMLClass
//
//  Created by Kieran McGrady http://www.kieranmcgrady.com
//  Twitter: http://twitter.com/kmcgrady
//
//
//  The MIT License
//
//  Copyright (c)
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy of 
//  this software and associated documentation files (the "Software"), to deal in 
//  the Software without restriction, including without limitation the rights to use, 
//  copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the 
//  Software, and to permit persons to whom the Software is furnished to do so, subject 
//  to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all 
//  copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, 
//  INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS 
//  FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS 
//  OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, 
//  WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF 
//  OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.


#import "KMXMLParser.h"


@implementation KMXMLParser
@synthesize delegate;

- (id)initWithURL:(NSString *)url delegate:(id)theDelegate;
{
    self.delegate = theDelegate;
	NSURL *xmlURL = [NSURL URLWithString:url];
	[self beginParsing:xmlURL];
    
    return self;
}

-(void)beginParsing:(NSURL *)xmlURL
{
	posts = [[NSMutableArray alloc] init];
	parser = [[NSXMLParser alloc] initWithContentsOfURL:xmlURL];
	[parser setDelegate:self];
	
	[parser setShouldProcessNamespaces:NO];
	[parser setShouldReportNamespacePrefixes:NO];
	[parser setShouldResolveExternalEntities:NO];
	
	[parser parse];
}

-(NSMutableArray *)posts
{
	return posts;
}

#pragma mark NSXMLParser Delegate Methods
- (void)parserDidStartDocument:(NSXMLParser *)parser
{
    [self.delegate parserDidBegin];
}

- (void)parserDidEndDocument:(NSXMLParser *)parser
{
    [self.delegate parserCompletedSuccessfully];
}

- (void)parser:(NSXMLParser *)parser parseErrorOccurred:(NSError *)parseError
{
    [self.delegate parserDidFailWithError:parseError];
}

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI 
 qualifiedName:(NSString *)qualifiedName attributes:(NSDictionary *)attributeDict
{
	element = [elementName copy];
	
	if ([elementName isEqualToString:@"item"]) 
	{
		elements = [[NSMutableDictionary alloc] init];
		title = [[NSMutableString alloc] init];
		date = [[NSMutableString alloc] init];
		summary = [[NSMutableString alloc] init];
		link = [[NSMutableString alloc] init];
	}
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI 
 qualifiedName:(NSString *)qName
{
	if ([elementName isEqualToString:@"item"]) 
	{
		[elements setObject:title forKey:@"title"];
		[elements setObject:date forKey:@"post"];
		[elements setObject:summary forKey:@"summary"];
		[elements setObject:link forKey:@"link"];
		
		[posts addObject:elements ];
	}
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string
{
	if ([element isEqualToString:@"title"]) 
	{
		[title appendString:string];
	} 
	else if ([element isEqualToString:@"pubDate"]) 
	{
		[date appendString:string];
	} 
	else if ([element isEqualToString:@"content:encoded"]) 
	{
		[summary appendString:string];
	} 
	else if ([element isEqualToString:@"link"]) 
	{
		[link appendString:string];
	} 
}


@end
