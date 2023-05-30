Class {
	#name : #GtIceCheckoutSelectedPackages,
	#superclass : #IceCheckoutSelectedPackages,
	#instVars : [
		'lepiterWorkingCopy'
	],
	#category : #'GToolkit4Git-Model'
}

{ #category : #accessing }
GtIceCheckoutSelectedPackages class >> isGtStrategy [
	^ true
]

{ #category : #accessing }
GtIceCheckoutSelectedPackages >> checkoutOn: anIceWorkingCopy [ 
	"Calling super performs a forced checkout. After this updates files from disk, trigger a reload of lepiter databases affected by this change."
	
	super checkoutOn: anIceWorkingCopy.
	lepiterWorkingCopy ifNil: [ ^ self ].
	lepiterWorkingCopy loadLepiterChangesInWorkingCopyFrom: self diff.
]

{ #category : #accessing }
GtIceCheckoutSelectedPackages >> lepiterWorkingCopy: aLepiterWorkingCopy [
	lepiterWorkingCopy := aLepiterWorkingCopy
]
