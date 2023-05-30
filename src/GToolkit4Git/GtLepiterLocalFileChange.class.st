Class {
	#name : #GtLepiterLocalFileChange,
	#superclass : #GtLepiterLocalChange,
	#instVars : [
		'path',
		'delta'
	],
	#category : #'GToolkit4Git-Lepiter'
}

{ #category : #accessing }
GtLepiterLocalFileChange >> delta [
	^ delta
]

{ #category : #accessing }
GtLepiterLocalFileChange >> delta: aGtDiffDelta [
	delta := aGtDiffDelta
]

{ #category : #accessing }
GtLepiterLocalFileChange >> path [
	^ path
]

{ #category : #accessing }
GtLepiterLocalFileChange >> path: aString [
	path := aString
]
