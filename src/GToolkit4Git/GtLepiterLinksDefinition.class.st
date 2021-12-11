Class {
	#name : #GtLepiterLinksDefinition,
	#superclass : #GtLepiterDefinition,
	#instVars : [
		'linksFileName',
		'linksContents'
	],
	#category : #'GToolkit4Git-Lepiter'
}

{ #category : #comparing }
GtLepiterLinksDefinition >> = anotherDefinition [

	^ super = anotherDefinition
		and: [ self linksFileName = anotherDefinition linksFileName 
			and: [ self linksContents = anotherDefinition linksContents ] ]
]

{ #category : #accessing }
GtLepiterLinksDefinition >> contents [ 
	^ self linksContents
]

{ #category : #comparing }
GtLepiterLinksDefinition >> hash [
	^ (super hash 
		bitXor: self linksFileName hash)
		bitXor: self linksContents hash
]

{ #category : #accessing }
GtLepiterLinksDefinition >> linksContents [

	^ linksContents
]

{ #category : #accessing }
GtLepiterLinksDefinition >> linksContents: anObject [

	linksContents := anObject
]

{ #category : #accessing }
GtLepiterLinksDefinition >> linksFileName [

	^ linksFileName
]

{ #category : #accessing }
GtLepiterLinksDefinition >> linksFileName: anObject [

	linksFileName := anObject
]
