Class {
	#name : #GtLepiterPageDefinition,
	#superclass : #GtLepiterDefinition,
	#instVars : [
		'pageUuid'
	],
	#category : #'GToolkit4Git-Lepiter'
}

{ #category : #accessing }
GtLepiterPageDefinition >> pageUuid [
	^ pageUuid
]

{ #category : #accessing }
GtLepiterPageDefinition >> pageUuid: anUuid [
	pageUuid := anUuid
]
