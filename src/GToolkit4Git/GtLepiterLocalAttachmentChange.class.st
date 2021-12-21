Class {
	#name : #GtLepiterLocalAttachmentChange,
	#superclass : #IceChange,
	#instVars : [
		'path',
		'delta'
	],
	#category : #'GToolkit4Git-Lepiter'
}

{ #category : #accessing }
GtLepiterLocalAttachmentChange >> delta [
	^ delta
]

{ #category : #accessing }
GtLepiterLocalAttachmentChange >> delta: aGtDiffDelta [
	delta := aGtDiffDelta
]

{ #category : #accessing }
GtLepiterLocalAttachmentChange >> path [
	^ path
]

{ #category : #accessing }
GtLepiterLocalAttachmentChange >> path: aString [
	path := aString
]
