Class {
	#name : #GtLepiterLocalPageChange,
	#superclass : #IceChange,
	#instVars : [
		'path',
		'delta'
	],
	#category : #'GToolkit4Git-Lepiter'
}

{ #category : #accessing }
GtLepiterLocalPageChange >> delta [
	^ delta
]

{ #category : #accessing }
GtLepiterLocalPageChange >> delta: aGtDiffDelta [
	delta := aGtDiffDelta
]

{ #category : #accessing }
GtLepiterLocalPageChange >> path [
	^ path
]

{ #category : #accessing }
GtLepiterLocalPageChange >> path: aString [
	path := aString
]
